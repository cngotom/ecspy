class AddLastCheckTimeToShopItem < ActiveRecord::Migration
  def change
  		add_column :shop_items , :last_check_time ,:datetime
  end
end
