class ShopItem < ActiveRecord::Base

	belongs_to :shop



	attr_accessible :title,:desc,:content,:price,:shop_id,:item_sn,:sales_count,:comments_count,:status

	acts_as_versioned :if => Proc.new { |item| item.changed? }

	VersiondAttr = [:title,:desc,:content,:price]

	self.non_versioned_columns << 'shop_id' 
	self.non_versioned_columns << 'item_sn' 
	self.non_versioned_columns << 'comments_count' 
	self.non_versioned_columns << 'sales_count'
	self.non_versioned_columns << 'status'


	class << self

		def find_or_create_by_sn(item_sn)
			res = find_by_item_sn(item_sn)
			res = new(:item_sn => item_sn) unless res
			res
		end





	end






	def changed?
		@changed || false
	end


	def update_if_changed(data)
		data = data.clone
		is_titile_or_price_changed = ( title != data['title'] ||  price != data['price']) 
		if is_titile_or_price_changed
			@changed = true
			assign_attributes(data)
			save
			@changed = false

		elsif (sales_count != data['sales_count'] ||  comments_count != data['comments_count'] )#|| shop_id!=data['shop_id']) 
			
			data.delete 'title'
			data.delete 'price'
			assign_attributes(data)
			save
		end
		is_titile_or_price_changed
	end


	def touch
		if !new_record?
			update_attribute(:updated_at,Time.new);
		end
	end


end
