class ItemSale < ActiveRecord::Base
	attr_accessible :item_price,:item_num, :user_name, :buy_time, :shop_item_id
end
