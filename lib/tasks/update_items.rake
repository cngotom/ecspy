require 'json'
require 'time'
require 'timeout'

desc 'auto update shop`s items'

Exec = 'phantomjs  --load-images=no'
ExecTB = 'phantomjs --load-images=yes'
Debug = '--debug=yes'
ScriptDir = File.join(Rails.root,'lib','tasks','phantomjs-script')

GetListLog = "log/phantomjs/getlist.log"
GetListRes = "log/phantomjs/getlist.res"


GetSalesLog  = "log/phantomjs/getsales.log"
GetSalesRes = "log/phantomjs/getsales.res"

def exec_with_timeout(cmd,timeout = 60,max_retry = 0)
	begin
		pipe = IO.popen(cmd)
		Timeout.timeout(timeout) do
			pipe.read
		end
	rescue Timeout::Error
		puts "#{cmd} time out "
		Process.kill 9, pipe.pid
		max_retry -= 1
		retry if max_retry >= 0 

		'killed because timeout'
	end
end


def lock(lockfile)
	raise 'pid file exist' if File.exists? lockfile
	f = File.open(lockfile,'w')
	f.puts Process.pid
	f.flock(File::LOCK_EX)

	delete_proc =  proc {
		File.delete lockfile if File.exists? lockfile
	}


	at_exit &delete_proc
	trap("KILL") &delete_proc
	begin
		yield if block_given?
	ensure
		f.close
		delete_proc.call
	end
end

require 'redis'
require 'redis-lock'
task :update_shop_items_list => :environment do
  

	$redis  = Redis.new

	

	out_file_ext = Time.new.strftime('.%Y-%m-%d-%H-%M')
	out_file = GetListRes + out_file_ext

	File.delete out_file if File.exist?(out_file)
	
	shops = Shop.recently_not_updated
	shops.each do |shop|
		puts "#{shop.title},last_updated: #{ shop.updated_at.strftime('%Y-%m-%d %H:%M:%S') }"
		puts "#{Exec} #{ScriptDir}/getlist.js #{shop.url} #{shop.id} #{out_file} #{GetListLog}"


		retn = exec_with_timeout("#{Exec} #{ScriptDir}/getlist.js #{shop.url} #{shop.id} #{out_file} #{GetListLog}")
		# => retn = 'ok'
		if retn.chomp == 'ok'




			puts 'execute ok'



			shop.touch

		else
			puts retn

		end
		
	end


	#handle GetListRes outfile
	if shops.size > 0
		open(out_file) do |out|
			out.each_line do |line|	
				data =  JSON.parse(line)

				data.delete	"comments_count" unless data['comments_count']
				data.delete	"sales_count" unless data['sales_count']
				
				

				item = ShopItem.find_or_create_by_sn(data['item_sn'])

				data.delete	"item_sn"
				item.update_if_changed(data)
				#item.touch

				#make item open
				item.update_status(0)


			end
		end

	end


end



desc 'auto update shop`s salesinfo'
task :update_shop_item_sales =>:environment do

	beg_time = Time.now 

	shopitems = ShopItem.recently_not_check

	item_count = shopitems.count
	shopitems.each do |item|
		puts "#{item.title},last_check_time: #{item.last_check_time.strftime('%Y-%m-%d %H:%M:%S') if item.last_check_time}"


		timestamp = item.last_check_time ? item.last_check_time.to_i : 0

		File.delete GetSalesRes if File.exist?(GetSalesRes)

		if item.shop.tmall?
			puts "#{Exec} #{ScriptDir}/getitem.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}"
			retn = exec_with_timeout("#{Exec} #{ScriptDir}/getitem.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}")
		else
			puts "#{ExecTB} #{ScriptDir}/getitem_tb.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}"
			retn = exec_with_timeout "#{ExecTB} #{ScriptDir}/getitem_tb.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}"
		end	

		# => retn = 'ok'
		if retn.chomp == 'ok'

			puts 'execute ok'

			if File.exist?(GetSalesRes)
				open(GetSalesRes) do |out|
					index = 0
					out.each_line do |line|	
						#first line is description
						if index == 0
							if !item.content
								item.create_content(:content=>line)
							else
								cont = item.content
								cont.update_if_changed(line)
							end
					
						else
							data =  JSON.parse(line)
							data['shop_item_id'] = item.id
							data['buy_time'] = Time.parse(data['buy_time'])
							ItemSale.create(data)
						end

						index += 1
					end
				end
			end


			item.check
		elsif retn.chomp == 'closed'
			puts "item: #{item.id} closed"
			item.update_status(1)
		else
			puts retn
		end

	end

	end_time = Time.now

	last_time = end_time - beg_time

	puts "crawl #{item_count} items, last_time: #{last_time} seconds ,per #{last_time / item_count} items/s" if item_count > 0


end






module GBKConvert
	def to_gbk
		gbk = self.encode("GBK","utf-8")
		s = ''
		gbk.bytes.each {|b|
			s << "%#{b.to_s(16).upcase}"
		}
		s
	end
	
end



desc "update ranks"
task :update_ranks => :environment do


	ShopKeyword.all.each do |keyword|

		key = keyword.keyword
		key.extend GBKConvert

		File.delete GetSalesRes if File.exist?(GetSalesRes)

		puts "#{Exec} #{ScriptDir}/getsearch.js #{keyword.id} #{key.to_gbk} #{GetSalesRes} #{GetSalesLog}"
		retn = exec_with_timeout "#{Exec} #{ScriptDir}/getsearch.js #{keyword.id} #{key.to_gbk} #{GetSalesRes} #{GetSalesLog}"
		# => retn = 'ok'
		if retn.chomp == 'ok'

			#merge
			if File.exist?(GetSalesRes)
				open(GetSalesRes) do |out|
					index = 0


					content = JSON.parse(out.read)
					keyid = content.shift

					shopkeyword = ShopKeyword.find(keyid)

					#get rank map
					rank_map = {}
					content.each_with_index do |item_id,index|
						rank_map[item_id] = index + 1 
					end

					#get all shop
					shops_ids = shopkeyword.shops

					shops_ids.split(',').map(&:to_i).each do |shopid|

						ShopItem.select('id,item_sn').where("shop_id = #{shopid}").each do |shopitem|
							#if shop item is find in rank_map
							if rank = rank_map[shopitem.item_sn]
								ShopKeywordRecord.create :shop_keyword_id => keyid ,:item_id => shopitem.id,:rank =>rank,:shop_id =>shopid
							end

						end

					end
			
				end
			end


		end

	end

end




desc "pre compare test"
task :pre_content_compare do 

	20.times do 
 		`phantomjs  --load-images=no lib/tasks/phantomjs-script/getitem.js 19943054675 1590315593 lib/tasks/log/phantomjs/getsales.res.compare lib/tasks/log/phantomjs/getsales.log`
	end

end




desc 'test item content compare'
task :content_compare =>:environment do

	open('lib/tasks/log/phantomjs/getsales.res.compare') do |out|
		last = nil
		out.each_line do |line|
			puts ShopItemContent.compare(line,last) if last
			last = line 
		end
	end

end


desc 'unique update item list'
task :uniq_item_list do
	lock('update_item_list.pid') do
		Rake::Task['update_shop_items_list'].invoke
	end
end


desc 'unique update item sales'
task :uniq_item_sales do
	lock('uniq_item_sales.pid') do
		Rake::Task['update_shop_item_sales'].invoke
	end
end




desc 'render preview'
task :uniq_render_preview => :environment do

	OutFileDir = File.join(Rails.root,'public','preview')

	lock('uniq_render_preview.pid') do

		today = Time.now.strftime('%Y-%m-%d')
		Shop.all.each do |shop|

			id = shop.id
			url = shop.url

			dir =  File.join(OutFileDir,"#{id}")

			FileUtils.mkdir_p(dir) unless File.directory?(dir)


			puts "start shop #{shop.id}"
			outfile = File.join(dir,"#{today}.jpg")
			height = `#{Exec} #{ScriptDir}/render_preview_h.js #{url} #{outfile}`

			res = exec_with_timeout("#{ExecTB} #{ScriptDir}/render_preview.js #{url} #{outfile} #{height}",60,3)


			#with convert
			if res.chomp == 'ok'
				outfile_small = outfile.gsub(".jpg","-small.jpg")
				`convert -resize x800 #{outfile} #{outfile_small}`
			end

		end
	end
end



task :test_retry do
	puts exec_with_timeout("sleep 2",1,3)

end


