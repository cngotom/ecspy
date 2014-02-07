

class UserCenter::ShopsController < InheritedResources::Base


  layout 'user_center'

  def index


  end


  def new
  	@shop = Shop.new
  end



  def create
    create! do |success, failure|
      success.html { redirect_to user_center_shops_path,:notice=>'create successful'}
    end
  end

  CurrentUser = 1


  def subscribe

  		shop_id = params['shop_id'].to_i

  		#@TODO replace with current_user
  		User.find(1).follow( Shop.find(shop_id)) 

  		render text: shop_id.to_s
  end


  def unsubscribe

  		shop_id = params['shop_id'].to_i

  		#@TODO replace with current_user

  		User.find(1).stop_following( Shop.find(shop_id)) 

  		render text: shop_id.to_s


  end



end


