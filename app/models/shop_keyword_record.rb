class ShopKeywordRecord < ActiveRecord::Base
  # attr_accessible :title, :body


  belongs_to :user
  belongs_to :shop_item,foreign_key: "item_id"
  belongs_to :shop
  belongs_to :shop_keyword

 
end
