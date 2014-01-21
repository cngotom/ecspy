ActiveAdmin.register Shop do
  
  	index do
      
 		selectable_column

 		column :id
        column :title

        column :url

        column :goods_num do  |shop|
        	shop.shop_items.count
        end

        column :created_at

        column :updated_at

        default_actions
    end

end
