require 'resque'
require 'tasks/crawler'
require "resque/tasks"


desc 'job coordinate'

task "resque:setup" => :environment



task :job_info do

	puts Resque.info[:pending]

	puts  Crawler::ItemListRedis.merged?
end

task :job_coord => :environment do

	if Resque.info[:pending] == 0 && Crawler::ItemListRedis.merged?
		Shop.recently_not_updated.each do |shop|
			Resque.enqueue( Crawler::ItemList,shop.id,shop.url )
		end

		ShopItem.select('title,last_check_time,id,item_sn').recently_not_check.each do |item|
			arr = item.attributes
			arr['timestamp'] = item.last_check_time ? item.last_check_time.to_i : 0
			arr['tmall?'] = ShopItem.find(item.id).shop.tmall?
			Resque.enqueue( Crawler::ItemSales,arr)
		end

	end

end


task :merge => :environment do

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
		#item.touch

		#make item open
		item.update_status(0)
		shop.touch

		puts "Shop:#{shop.id} item:#{item.id}  merge ok"
	end


	#merge items
	sales_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemSales')
	while (data = sales_redis_client.pop) != nil do
			data =  JSON.parse(data)
			data['shop_item_id'] = data['id']
			data['buy_time'] = Time.parse(data['buy_time'])
			item = ShopItem.find(data['id'])
			data.delete 'id'
			ItemSale.create(data)


			item.update_attribute(:last_check_time,Time.at(data['last_check_time'].to_i) ) if data['last_check_time']
	end




	#merge item close
	closed_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemClosed')
	while (data = closed_redis_client.pop) != nil do
		data =  JSON.parse(data)
		item = ShopItem.find(data['id'])
		item.update_status(1)
	end



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

	puts Time.new - beg
end
  

