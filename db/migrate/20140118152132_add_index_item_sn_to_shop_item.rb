class AddIndexItemSnToShopItem < ActiveRecord::Migration
  def change
  	 add_index :shop_items, :item_sn,:unique => true
  end
end
