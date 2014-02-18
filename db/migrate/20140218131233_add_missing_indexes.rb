class AddMissingIndexes < ActiveRecord::Migration
 
 	def change


 		add_index :shops ,:updated_at

 		add_index :shops ,:created_at

 		add_index :item_sales, :buy_time
 	 	
 	 	add_index :shop_items, :last_check_time


 	 	add_index :shop_item_versions, :updated_at


 	 	add_index :shop_item_content_versions, :updated_at

 	 	add_index :shop_item_content_versions, ["shop_item_content_id"], :name => "index_shop_item_contents_versions_on_shop_item_id"

 	end
end
