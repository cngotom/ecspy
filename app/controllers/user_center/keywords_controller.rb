#encoding:utf-8
class UserCenter::KeywordsController < ApplicationController
	before_filter :authenticate_user!
	layout 'user_center'

	def index
		@shops_map ={}
	 	Shop.watched(current_user.id).each do |r|
	 		@shops_map[r.id] = r.title
		end
		@keywords = current_user.keywords
	end


	def new
	  	@keyword = ShopKeyword.new
	end



	def create

	 	data = params[:shop_keyword]
	 	data["shops"] = data["shops"].join(",").chomp(',')
	 	data["user_id"] = current_user.id

	 	@keyword = ShopKeyword.new(data)
		if @keyword.save
			flash[:notice] = '关键字创建成功.'
			redirect_to :action => :index
		else

			render :action => :new
		end
	end


	def destroy
		  @keyword = ShopKeyword.find(params[:id])
		  @keyword.destroy
		  flash[:notice] = '删除成功.'
		  redirect_to :action => :index

	end
end
