class UserCenterController < ApplicationController
  before_filter :authenticate_user!
  layout 'user_center'


  def index
  	@offset = params['offset'].to_i
  	@shops = current_user.following_by_type('Shop')

  end


end

