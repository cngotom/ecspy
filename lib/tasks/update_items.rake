require 'json'
require 'time'
desc 'auto update shop`s items'

Exec = 'phantomjs  --load-images=no'
ExecTB = 'phantomjs --load-images=yes'
Debug = '--debug=yes'
ScriptDir = File.join(Rails.root,'lib','tasks','phantomjs-script')

GetListLog = "log/phantomjs/getlist.log"
GetListRes = "log/phantomjs/getlist.res"


GetSalesLog  = "log/phantomjs/getsales.log"
GetSalesRes = "log/phantomjs/getsales.res"



def lock(lockfile)
	raise 'pid file exist' if File.exists? lockfile
	f = File.open(lockfile,'w')
	f.puts Process.pid
	f.flock(File::LOCK_EX)
	begin
		yield if block_given?
	ensure
		f.close
		File.delete lockfile
	end
end


task :update_shop_items_list => :environment do
  


	out_file_ext = Time.new.strftime('.%Y-%m-%d-%H-%M')
	out_file = GetListRes + out_file_ext

	shops = Shop.recently_not_updated
	shops.each do |shop|
		puts "#{shop.title},last_updated: #{ shop.updated_at.strftime('%Y-%m-%d %H:%M:%S') }"
		puts "#{Exec} #{ScriptDir}/getlist.js #{shop.url} #{shop.id} #{out_file} #{GetListLog}"
		retn = `#{Exec} #{ScriptDir}/getlist.js #{shop.url} #{shop.id} #{out_file} #{GetListLog}`
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
			retn = `#{Exec} #{ScriptDir}/getitem.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}`
		else
			puts "#{ExecTB} #{ScriptDir}/getitem_tb.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}"
			retn = `#{ExecTB} #{ScriptDir}/getitem_tb.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}`
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
