require 'json'
desc 'auto update shop`s items'

Exec = 'phantomjs '
Debug = '--debug=yes'
ScriptDir = File.join(Rails.root,'lib','tasks','phantomjs-script')

GetListLog = "log/phantomjs/getlist.log"

GetListRes = "log/phantomjs/getlist.res"
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
