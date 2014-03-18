class UserCenterController < ApplicationController
	
  helper StaticsHelper
  before_filter :authenticate_user!
  layout 'smart_admin'


  def index
  	@offset = params['offset'].to_i
  	@shops = current_user.following_by_type('Shop')

  end


end

