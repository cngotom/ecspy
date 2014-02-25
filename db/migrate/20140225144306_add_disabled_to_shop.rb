class AddDisabledToShop < ActiveRecord::Migration
  def change
  	add_column :shops,:disabled,:integer,:default => 0
  	add_index :shops ,:disabled
  end
end
