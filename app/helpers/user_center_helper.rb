#encoding:utf-8
module UserCenterHelper

	def link_with_cur(path,title)
		cur = 'cur' if request.path == path
		"<li><a href='#{path}' class='#{cur}'><i class='icon-chevron-right'></i> #{title} </a></li>"
	end



	def today_change_count(shop,offset =0)

			 ShopItemVersion.today_changes(shop,offset).size +  
			 ShopItemContentVersion.today_changes(shop,offset).size
	end
	
	def today_changes(shop,offset=0)


		res = []

  		today_changes = ShopItemVersion.today_changes(shop,offset)
		
		today_changes_cache = {}
  		today_changes.each do |r|
  			today_changes_cache["#{r.shop_item_id}_#{r.version}"] = r
  		end

		today_changes.each do |r|
			item = today_changes_cache["#{r.shop_item_id}_#{r.version}"]

			if item.version != 1
				last = item
				prev = today_changes_cache["#{r.shop_item_id}_#{r.version-1}"]

				if prev.nil?
					prev = ShopItemVersion.includes(:shop_item).where(:shop_item_id => r.shop_item_id,:version=>r.version-1).limit(1).first
				end


				change = "［商品］：<a href='/shop_items/#{item.shop_item.id}' >#{last.title}</a> "

				change += " 价格变化 #{prev.price} => #{last.price}" if last.price != prev.price

				change += " 标题变化 #{prev.title} => #{last.title}" if last.title != prev.title
				
				change += " 状态变化 #{ShopItem.status_text prev.status} => #{ShopItem.status_text last.status}" if last.status != prev.status

				change += " 主图变化 #{image_tag prev.thumb,:class=>'small'} => #{image_tag last.thumb,:class=>'small'}" if last.thumb != prev.thumb

			else
				change = "［新品］:<a href='/shop_items/#{item.shop_item.id}' >#{item.title}</a> 新上架"

			end

			res << change

		end 




	 	ShopItemContentVersion.today_changes(shop,offset).each do |r|
	 		item = ShopItemContent.find(r.shop_item_content_id)
	 		if item.versions.count != 1
		 		last = item.versions.last
				prev = last.previous


		 		change = "［内容］:<a href='/shop_items/#{item.shop_item.id}' >#{item.shop_item.title}</a> 内容变化 "

				change +=  " <a href='/shop_items/#{item.shop_item.id}/content/#{last.version}/#{prev.version}' > 对比 </a>"

				#{content_compare_path(:id=>item.shop_item.id,:fversion=>last.version,:sversion=>prev.version)}

			else
				change = "［内容］:<a href='/shop_items/#{item.shop_item.id}' >#{item.shop_item.title}</a> 内容创建"

			end

			res << change

	 	end


	 	res

	end


	def today_sales(shop,offset=0)
		res = {}
		sales = shop.today_sales(offset)
		sales.each do |s|
			if !res[s.shop_item.id]
				row = {}
				row['item'] = link_to s.shop_item.title, "/shop_items/#{s.shop_item.id}"
				row['img'] = link_to image_tag(s.shop_item.thumb),"/shop_items/#{s.shop_item.id}"
				row['count'] = s.item_num.to_i
				row['money'] = s.item_num.to_i * s.item_price.to_f
				res[s.shop_item.id] = row
			else
				res[s.shop_item.id]['count'] += s.item_num.to_i
				res[s.shop_item.id]['money'] += s.item_num.to_i* s.item_price.to_f
			end
		end
		res = res.to_a.sort do |a,b|
			b[1]['money'] <=>  a[1]['money']
		end
		res
	end


	def get_preview(id,time)
		"/preview/#{id}/#{time.strftime('%Y-%m-%d')}.jpg"
	end

	def get_preview_small(id,time)
		"/preview/#{id}/#{time.strftime('%Y-%m-%d')}-small.jpg"
	end


	def get_change_icon(status)
		if status == 1
			'<img src="/assets/zeng.gif">'.html_safe
		else
			'<img src="/assets/jian.gif">'.html_safe
		end

	end

	def get_sales_history(shop,offset)
		start_time = Time.now.end_of_day-30*24*3600 -offset*24*3600 
		end_time = Time.now.end_of_day-offset*24*3600
		#ShopItem.includes(:shop_item).
		#ItemSale.joins(:shop_item).select('date_format(buy_time,"%y-%m-%d") as time ,sum(item_price * item_num) as total').where(['shop_id = 1 and buy_time between ? and ?',Time.now-3*24*3600 , Time.now]).group('time')
		sales = ItemSale.joins(:shop_item).select(' date_format(buy_time,"%y-%m-%d") as time,sum(item_num) as item_count, sum(item_price * item_num) as total').where(['shop_id = ? and buy_time between ? and ?',shop.id,start_time,end_time]).group('time').order('time asc')
		
		res = []
		start_time_stamp = start_time.beginning_of_day.to_i
		end_time_stamp = end_time.beginning_of_day.to_i
		current_time_stamp = start_time_stamp
		one_day_sec = 3600*24
		
		sales_index = 0
		31.times do |i|
			if Time.at(current_time_stamp).strftime('%y-%m-%d') == sales[sales_index].time
				res << [ sales[sales_index].item_count.to_i,sales[sales_index].total.round(2)]
				sales_index += 1
				sales_index = 0 if sales_index >= sales.size
			else
				res << [0,0]
			end

			current_time_stamp += one_day_sec
		end
		res
	end


	def get_sales_money_history(shop,offset)
		res = get_sales_history(shop,offset)
		res.collect &:second
	end


	def get_sales_count_history(shop,offset)
		res = get_sales_history(shop,offset)
		res.collect &:first
	end
	#sales_history = get_sales_histroy(@shop,offset)

end
