class AddStatusToShopItem < ActiveRecord::Migration
  def change
  		add_column :shop_items,:status,:integer,:default => 0
  end
end
