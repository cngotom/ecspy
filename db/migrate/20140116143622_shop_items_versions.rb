class ShopItemsVersions < ActiveRecord::Migration
  def up
  	ShopItem.create_versioned_table
  end

  def down
  	ShopItem.drop_versioned_table
  end
end
