class AddCommentsCountToShopItems < ActiveRecord::Migration
  def change
  		add_column :shop_items,:comments_count,:integer
  		add_column :shop_items,:sales_count,:integer
  end
end
