#encoding:utf-8
class Nav
	
	class << self
		delegate :user_root_path,:user_center_keywords_path,:user_center_keyword_records_path,:user_center_shops_path,
		:new_user_center_keyword_path,:user_center_shop_path,:new_user_center_shop_path,:user_center_items_path, to: 'Rails.application.routes.url_helpers' 
	end

	NavGrid = {
		"dashboard" => {
			"title" => "首页",
			"url" => user_root_path,
			"icon" => "fa-home",
		},
		"search" => {
			"title" => "关键字",
			"icon" => "fa-search",
			"sub" => {
				
				'rank' => {

					"title" => '排名',
					'url' => user_center_keyword_records_path
				},
				'add' => {
					'title' =>'新增',
					'url' => new_user_center_keyword_path

				},
				'setup' => {
					"title" => "查看",
					"url" => user_center_keywords_path

				}

			}
		},
		"shop" => {
			"title" => '店铺',
			'icon' => 'fa-archive',
			'sub' => {

				'subscribe' => {
					'title' => '管理',
					'url' => user_center_shops_path
				} ,
				'add' => {
						'title' => '新增',
						'url' => new_user_center_shop_path
				},

			}

		}


	}



	FetchArgs = proc do |nav_item|

		url = nav_item["url"] ? nav_item["url"] : "#";
		icon_badge = nav_item["icon_badge"] ? "<em> #{nav_item["icon_badge"]} </em> " : '';

		icon = nav_item["icon"] ? "<i class='fa fa-lg fa-fw #{nav_item['icon']}'> #{icon_badge} </i> " : "";
		nav_title = nav_item["title"] ? nav_item["title"] : "(No Name)";
		label_htm = nav_item["label_htm"] ? nav_item["label_htm"] : "";
	

		[url,icon,nav_title,label_htm]
	end




	class << self



		def to_html(path)
			#@res ||=
			generate_html(path)
		end


		def breadcrumb(path)
			navs = tree_by_path[path]
			res = ''
			if navs
				navs.each do |nav|
					res +=  "<li> #{nav} </li>"
				end
			end
			res.html_safe
		end

		def breadcrumb_exits(path)
			navs = tree_by_path[path]
			navs
		end


		def set_current_shop(shop)
			@shop = shop
			@nav_with_shop_grid = _shop_nav_grid(shop) if shop && shop.id
		end



		private

		def _shop_nav_grid(shop)
			ext = {
				'add' => {
					'title' => '新增',
					'url' => new_user_center_shop_path
				} ,
				'today' => {
					'title' => '当日数据',
					'url' => user_center_shop_path(shop)
				} ,
				'items' => {
					'title' => '产品',
					'url' => user_center_items_path({'shop_id'=>shop.id})
				} 

			}
			res = NavGrid.deep_dup

			res['shop']['sub'].merge!  ext
			res

		end


		def nav_grid
			if @shop && @shop.id
				@nav_with_shop_grid
			else
				NavGrid
			end
		end



		def _get_tree_path(hash,_trees)

			ret = {}
			hash.each do |key,value|
				trees = _trees.dup
				ret[value['url']] = trees.push(value['title'])

				if value['sub']
					ret.merge!  _get_tree_path(value['sub'],ret[value['url']])
				end
			end
			ret
		end

		def tree_by_path
			#@navs_tree_by_path ||= 
			_get_tree_path(nav_grid,[])
		end

		def generate_html(path)
			ret = ''
			nav_grid.each do |key,nav_item| 	
				#process parent nav
				nav_htm = '';
				


				url,icon,nav_title,label_htm = FetchArgs[nav_item]

				nav_htm += "<a href='#{url}' title='#{nav_title}'> #{icon} <span class='menu-item-parent'>#{nav_title} </span> #{label_htm}</a>";

				if ( nav_item["sub"]) 
					nav_htm += process_sub_nav(nav_item["sub"],path);
				end
				ret = ret + "<li  #{'class = \"active\"' if path == url}  >#{nav_htm}</li>";


			end
			ret.html_safe


		end
		
		def process_sub_nav(nav_item,path)

			sub_item_htm = "";
			
			if nav_item["sub"]
				sub_nav_item = nav_item["sub"];
				sub_item_htm = process_sub_nav sub_nav_item,path
			else
				sub_item_htm += '<ul>'
				nav_item.each do |key,sub_item|
					url,icon,nav_title,label_htm = FetchArgs[sub_item]


					sub_item_htm += 
						"<li #{'class = "active"' if url == path}  >
							<a href='#{url}'> #{icon} #{nav_title} #{label_htm} </a>
							#{ process_sub_nav(sub_item['sub']) if sub_item['sub'] }
						</li>";
				end
				sub_item_htm += '</ul>';
				
			end

			sub_item_htm

		end

	end

	


	

	

end