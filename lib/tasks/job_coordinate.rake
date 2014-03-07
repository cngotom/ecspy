require 'resque'
require 'tasks/crawler'
require "resque/tasks"


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

desc 'job coordinate'

task "resque:setup" => :environment



task :job_info do

	puts Resque.info[:pending]

	puts  Crawler::ItemListRedis.merged?

	puts  Crawler::ItemListRedis.size
end

task :job_coord => :environment do
	lock('job_coord.pid') do
		if Resque.info[:pending] == 0 && Crawler::ItemListRedis.merged?
			puts 'job coord'
			Shop.recently_not_updated.each do |shop|
				Resque.enqueue( Crawler::ItemList,shop.id,shop.url )
				shop.touch
			end

			ShopItem.select('title,last_check_time,id,item_sn').recently_not_check.each do |item|
				arr = item.attributes
				arr['timestamp'] = item.last_check_time ? item.last_check_time.to_i : 0


				shop = ShopItem.find(item.id).shop

				if shop
					arr['tmall?'] = shop.tmall?
					Resque.enqueue( Crawler::ItemSales,arr) 
				end
			end

		end
	end
end


task :job_keyword => :environment do

	ShopKeyword.all.each do |keyword|

		key = keyword.keyword
		id = keyword.id

		Resque.enqueue( Crawler::Keyword,id,key) 
	
	end
end



def merge 
	beg = Time.new
	#merge item list
	list_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemList')
	while (data = list_redis_client.pop) != nil do
		data = JSON.parse(data)

		shop = Shop.find(data['shop_id'])


		data.delete	"comments_count" unless data['comments_count']
		data.delete	"sales_count" unless data['sales_count']
		
		item = ShopItem.find_or_create_by_sn(data['item_sn'])

		data.delete	"item_sn"
		item.update_if_changed(data)

		#make item open
		item.update_status(0)

		puts "Shop:#{shop.id} item:#{item.id}  merge ok"
	end
	list_redis_client.close

	#merge items
	sales_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemSales')
	while (data = sales_redis_client.pop) != nil do
			data =  JSON.parse(data)
			data['shop_item_id'] = data['id']
			data['buy_time'] = Time.parse(data['buy_time'])
			item = ShopItem.find(data['id'])


			data['item_price'] = item.price unless data['item_price']
			
			item.update_attribute(:last_check_time,Time.at(data['last_check_time'].to_i) ) if data['last_check_time']


			data.delete 'id'
			data.delete 'last_check_time'


			ItemSale.create(data)


	end
	sales_redis_client.close



	#merge item close
	closed_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemClosed')
	while (data = closed_redis_client.pop) != nil do
		data =  JSON.parse(data)
		item = ShopItem.find(data['id'])
		item.update_status(1)
	end
	closed_redis_client.close


	#merge  item contents
	content_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemContent')
	while (data = content_redis_client.pop) != nil do
		data =  JSON.parse(data)
		item = ShopItem.find(data['id'])
		if !item.content
			item.create_content(:content=>data['content'])
		else
			cont = item.content
			cont.update_if_changed(data['content'])
		end


		item.update_attribute(:last_check_time,Time.at(data['last_check_time'].to_i) ) if data['last_check_time']
	end
	content_redis_client.close



	#merge keyword
	keyword_redis_client =  Crawler::ItemListRedis.new(:key => 'RedisKeyword')
	while (data = keyword_redis_client.pop) != nil do
		content = JSON.parse(data)
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
	keyword_redis_client.close

	

	puts Time.new - beg

end

task :merge => :environment do
	merge
end
  
task :merge_daemon => :environment do 
	    lock('merge_daemon.pid') do
        	while true do
            	begin
                    merge
                rescue Timeout::Error
                    puts 'time out'
                rescue
                    puts $!
                    puts $@
	            end
                sleep 30
                puts 'sleep'
        	end
       end
end

task :resque_work do 
	while true do
		Rake::Task['resque:work'].invoke rescue puts $!
		Rake::Task['resque:work'].reenable
		puts 'retry'
		sleep 30
	end

end
