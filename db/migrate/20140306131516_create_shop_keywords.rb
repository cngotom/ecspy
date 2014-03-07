class CreateShopKeywords < ActiveRecord::Migration
  def change
    create_table :shop_keywords do |t|
      t.string :keyword
      t.string :shops
      t.integer :user_id

      t.timestamps
    end

    add_index :shop_keywords, :user_id
    add_index :shop_keywords, :keyword
  end
end
