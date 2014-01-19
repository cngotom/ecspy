class CreateShopItems < ActiveRecord::Migration
  def change
    create_table :shop_items do |t|
      t.string :title
      t.string :desc
      t.text :content
      t.float :price
      t.integer :shop_id
      t.string :item_sn

      t.timestamps
    end
  end
end
