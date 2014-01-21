class CreateItemSales < ActiveRecord::Migration
  def change
    create_table :item_sales do |t|
      t.string :user_name
      t.string :user_level
      t.float :item_price
      t.integer :item_num
      t.datetime :buy_time
      t.integer :shop_item_id
    end

    add_index :item_sales, :shop_item_id
  end
end
