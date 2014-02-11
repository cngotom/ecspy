class UserCenter::ItemsController < ApplicationController
	before_filter :authenticate_user!
	layout 'user_center'

	def index
		@tasks_grid = initialize_grid(ShopItem,
		:include => [:shop],
	     :custom_order => {
	    })
	end

end
