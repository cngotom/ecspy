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




	def today_sales_count
		shop_items.inject(0) {|sum,item|
			puts " #{item.id} #{item.title} #{item.today_sales_count}"
			
			sum + item.today_sales_count
		}
	end

	def today_sales_money
		shop_items.inject(0) {|sum,item| 
			#puts " #{item.id} #{item.title} #{item.today_sales_money} #{item.today_sales_money}"
			sum + item.today_sales_money
		}
	end


end
