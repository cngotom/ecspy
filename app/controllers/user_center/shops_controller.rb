

class UserCenter::ShopsController < InheritedResources::Base
  include StaticsHelper
  include UserCenterHelper

  before_filter :authenticate_user!

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



  def subscribe

  		shop_id = params['shop_id'].to_i

  		#@TODO replace with current_user
  		current_user.follow( Shop.find(shop_id)) 

  		render text: shop_id.to_s
  end


  def unsubscribe

  		shop_id = params['shop_id'].to_i

  		#@TODO replace with current_user

  		current_user.stop_following( Shop.find(shop_id)) 

  		render text: shop_id.to_s


  end



  def compare

    @offset = params['offset'].to_i
    @offset ||= 0
    shops = params['id'].split(',')
    shops.collect! &:to_i



    @res = []

    shops.each do |s|
      shop = Shop.find(s)
      row = {'title' => shop.title,'id'=>shop.id}
      row['sales'] = get_sales_history(shop,@offset)

      
      @res << row
    end

  end


  def show
    #time = Time.now.beginning_of_day
    offset = params['offset'].to_i

    offset ||= 0
    @shop = Shop.find(params['id'])

    @today = calc_sales_count_and_money(@shop.today_sales(offset))

    yesterday = calc_sales_count_and_money(@shop.today_sales(offset + 1 ))

    lastweekday = calc_sales_count_and_money(@shop.today_sales(offset + 7 ))



    today_changes_sales = today_changes(@shop.id,offset)

    @yes_compare = get_compare_rate(@today,yesterday)

    @lastweekday_compare = get_compare_rate(@today,lastweekday)

    sales_history = get_sales_money_history(@shop,offset)
    count_history = get_sales_count_history(@shop,offset)

    sales_total = sales_history.inject(0) {|sum,i| sum + i} 
    count_total= count_history.inject(0) {|sum,i| sum + i} 


    @locals = { :today => @today,:lastweekday_compare => @lastweekday_compare, :sales_history=>sales_history,:count_history => count_history,
    :yes_compare => @yes_compare ,:shop => @shop ,:offset=>offset,:today_changes_sales => today_changes_sales,
    :sales_total =>sales_total,:count_total=>count_total

    }

    #hack ugly?
    respond_to do |format|
      format.html
      format.js {
         render :partial => 'show_data',:locals => @locals,:layout=>false ,:mime_type => Mime::Type.lookup('text/html')
      }
    end

    #5 top items
  end





end


