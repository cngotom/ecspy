class CreateShopItemContents < ActiveRecord::Migration
  def change
    create_table :shop_item_contents do |t|
      t.text :content
      t.integer :shop_item_id

      t.timestamps
    end


    add_index :shop_item_contents, :shop_item_id
  end
end
