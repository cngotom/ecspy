ActiveAdmin.register Shop do

    controller do
        def scoped_collection
            Shop.unscoped
        end


       
    end
  
    batch_action :disabled do |selection|
        Shop.unscoped.find(selection).each do |shop|
            shop.disabled = 1 
            shop.save :validate => false
        end
        redirect_to admin_shops_path, :notice => "Shops disabled!"

    end

    batch_action :enabled do |selection|
        Shop.unscoped.find(selection).each do |shop|
            shop.disabled = 0
            shop.save :validate => false
        end
        redirect_to admin_shops_path, :notice => "Shops enabled!"

    end


  

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

        column :disabled do  |shop|
           (shop.disabled==1) ? 'true' : 'false'
        end

        default_actions


        

    end

end
