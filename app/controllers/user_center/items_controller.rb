class UserCenter::ItemsController < ApplicationController
	before_filter :authenticate_user!
	layout 'smart_admin'

	def index
		shop_id = params['shop_id'].to_i
		@shop = Shop.find(shop_id)
		where = "shop_id = #{shop_id}" if shop_id > 0
		@tasks_grid = initialize_grid(ShopItem,
		:include => [:shop],
		:conditions => where,
	     :custom_order => {
	    })
	end

end
