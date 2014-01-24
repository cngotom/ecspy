class ShopItemContentVersions < ActiveRecord::Migration
   def up
  	ShopItemContent.create_versioned_table
  end

  def down
  	ShopItemContent.drop_versioned_table
  end
end
