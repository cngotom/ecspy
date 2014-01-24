class ShopItemContent < ActiveRecord::Base

	acts_as_versioned

	attr_accessible :content
	self.non_versioned_columns << 'shop_item_id' 


	belongs_to :shop_item




	def update_if_changed(cont)
		is_content_changed =  ( self.content != cont)

		if is_content_changed
			self.content = cont
			save
		else

			false
		end

	end

end
