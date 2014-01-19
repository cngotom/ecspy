class Shop < ActiveRecord::Base
	attr_accessible :title,:url,:goods_num

	has_many :shop_items

	#not update in 6 hours or created in 6 hours
	scope :recently_not_updated,where( ["updated_at < ? or ( created_at > ?  and updated_at = created_at )", Time.now - 6.hour, Time.now - 6.hour])


	def touch
		if !new_record?
			update_attribute(:updated_at,Time.new);
		end
	end
end
