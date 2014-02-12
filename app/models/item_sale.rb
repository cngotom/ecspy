class ItemSale < ActiveRecord::Base
	attr_accessible :item_price,:item_num, :user_name, :buy_time, :shop_item_id
	belongs_to :shop_item

	has_one :shop ,:through => :shop_item,:source => :shop
end
