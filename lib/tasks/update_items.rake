require 'json'
require 'time'
desc 'auto update shop`s items'

Exec = 'phantomjs'
Debug = '--debug=yes'
ScriptDir = File.join(Rails.root,'lib','tasks','phantomjs-script')

GetListLog = "log/phantomjs/getlist.log"
GetListRes = "log/phantomjs/getlist.res"


GetSalesLog  = "log/phantomjs/getsales.log"
GetSalesRes = "log/phantomjs/getsales.res"

task :update_shop_items_list => :environment do
  


	out_file_ext = Time.new.strftime('.%Y-%m-%d-%H-%S')
	out_file = GetListRes + out_file_ext

	shops = Shop.recently_not_updated
	shops.each do |shop|
		puts "#{shop.title},last_updated: #{ shop.updated_at.strftime('%Y-%m-%d %H:%M:%S') }"
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



			end
		end

	end


end



desc 'auto update shop`s salesinfo'
task :update_shop_item_sales =>:environment do

	shopitems = ShopItem.recently_not_check

	shopitems.each do |item|
		puts "#{item.title},last_check_time: #{item.last_check_time.strftime('%Y-%m-%d %H:%M:%S') if item.last_check_time}"


		timestamp = item.last_check_time ? item.last_check_time.to_i : 0

		puts "#{Exec} #{ScriptDir}/getitem.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}"
		retn = `#{Exec} #{ScriptDir}/getitem.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}`
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
								item.create_content
							end
							cont = item.content
							cont.update_if_changed(line)
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

		else
			puts retn
		end

		File.delete GetSalesRes if File.exist?(GetSalesRes)

	end



end