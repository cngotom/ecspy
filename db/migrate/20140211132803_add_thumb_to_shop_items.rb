class AddThumbToShopItems < ActiveRecord::Migration
  def change
  	add_column :shop_items , :thumb ,:string
  	add_column :shop_item_versions , :thumb ,:string
  end
end
