class ShopItemsController < InheritedResources::Base
  	include UserCenterHelper

	before_filter :authenticate_user!
  	layout 'smart_admin'

	def content_compare

		shop_item = ShopItem.find(params[:id])

		fversion = params[:fversion].to_i

		sversion = params[:sversion].to_i

		content = shop_item.content
		fres = content.revert_to fversion
		@fcontent = content.content


		sres = content.revert_to sversion
		@scontent = content.content


		@fcontent = ''  unless  @fcontent
		@scontent = ''  unless @scontent
			

		if !fres || !sres
			raise  "unknow version"
		end

	end



	def show

		id = params[:id].to_i
		@shop_item = ShopItem.find(id)
	

		@sales_history = get_sales_money_history(id,0,:by_item)
	    @count_history = get_sales_count_history(id,0,:by_item)

	    @sales_total = @sales_history.inject(0) {|sum,i| sum + i} 
	    @count_total= @count_history.inject(0) {|sum,i| sum + i} 

	end





end
