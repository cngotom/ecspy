class CreateShopKeywordRecords < ActiveRecord::Migration
  def change
    create_table :shop_keyword_records do |t|

      t.integer :shop_keyword_id
      t.integer :item_id
      t.integer :shop_id
      t.integer :rank

      t.datetime :created_at
    end

      add_index :shop_keyword_records, :shop_keyword_id
      add_index :shop_keyword_records, :item_id
      add_index :shop_keyword_records, :shop_id
      add_index :shop_keyword_records, :rank

      add_index :shop_keyword_records, :created_at
  end
end
