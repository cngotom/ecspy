class ShopItemsController < InheritedResources::Base


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








end
