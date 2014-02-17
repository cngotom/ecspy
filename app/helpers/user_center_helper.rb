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
					prev = ShopItemVersion.includes(:shop_item).where(:shop_item_id => r.shop_item_id,:version=>r.version).limit(1).first
				end


				change = "［商品］：<a href='#{shop_item_path(item)}' >#{last.title}</a> "

				change += " 价格变化 #{prev.price} => #{last.price}" if last.price != prev.price

				change += " 标题变化 #{prev.title} => #{last.title}" if last.title != prev.title
				
				change += " 状态变化 #{ShopItem.status_text prev.status} => #{ShopItem.status_text last.status}" if last.status != prev.status

				change += " 主图变化 #{image_tag prev.thumb,:class=>'small'} => #{image_tag last.thumb,:class=>'small'}" if last.thumb != prev.thumb

			else
				change = "［新品］:<a href='#{shop_item_path(item)}' >#{item.title}</a> 新上架"

			end

			res << change

		end 




	 	ShopItemContentVersion.today_changes(shop,offset).each do |r|
	 		item = ShopItemContent.find(r.shop_item_content_id)
	 		if item.versions.count != 1
		 		last = item.versions.last
				prev = last.previous


		 		change = "［内容］:<a href='#{shop_item_path(item.shop_item)}' >#{item.shop_item.title}</a> 内容变化 "

				change +=  " <a href='#{content_compare_path(:id=>item.shop_item.id,:fversion=>last.version,:sversion=>prev.version)}' > 对比 </a>"

			else
				change = "［内容］:<a href='#{shop_item_path(item.shop_item)}' >#{item.shop_item.title}</a> 内容创建"

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
				row['item'] = link_to s.shop_item.title,shop_item_path(s.shop_item)
				row['img'] = link_to image_tag(s.shop_item.thumb),shop_item_path(s.shop_item)
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

end
