class AddIndexToRefrenceTables < ActiveRecord::Migration
  def change
  	 add_index :shop_items, :shop_id
  end
end
