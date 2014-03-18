class UserCenter::KeywordRecordsController < ApplicationController

	before_filter :authenticate_user!
 	layout 'smart_admin'


	def index

		# @records = []
		# ShopKeywordRecord.includes(:shop,:shop_item,:shop_keyword).select('t3.user_id').where("user_id =  #{current_user.id}").each do |r|
		# 	@records << {
		# 		'title' => r.shop.title,
		# 		'shop_id'=>r.shop_id,
		# 		'item_title' => r.shop_item.title,
		# 		'item_id' => r.item_id,
		# 		'rank' => r.rank,
		# 		'keyword' => r.shop_keyword.keyword
		# 	}

		# end	

		last_time = Time.now.beginning_of_day
		if ShopKeywordRecord.where(['created_at > ?',last_time]).size == 0
			last_time = last_time - 1.day
		end
		@records = initialize_grid(
		  ShopKeywordRecord.includes(:shop,:shop_item,:shop_keyword).select('shop_keywords.user_id').where("user_id = 1 ").where(['

		  	shop_keyword_records.created_at >=?',last_time]),

	     :custom_order => {
	    })
	end

		

	def trend
		record = ShopKeywordRecord.find(params[:id])


		start_time = Time.now.end_of_day-30.days
		end_time = Time.now.end_of_day


		records = ShopKeywordRecord.select(' date_format(created_at,"%y-%m-%d") as time,avg(rank) as rank').where(
			['shop_id = ? and item_id = ? and shop_keyword_id = ? and created_at between ? and ?',record.shop_id,record.item_id,record.shop_keyword_id,start_time,end_time]).group('time').order('time asc')



		res = []
		start_time_stamp = start_time.beginning_of_day.to_i
		end_time_stamp = end_time.beginning_of_day.to_i
		current_time_stamp = start_time_stamp
		one_day_sec = 1.day
		
		index = 0
		31.times do |i|
			if Time.at(current_time_stamp).strftime('%y-%m-%d') == records[index].time
				res << records[index].rank
				index += 1
				index = 0 if index >= records.size
			else
				res << 0
			end

			current_time_stamp += one_day_sec
		end
		res

		respond_to do |format|
		  format.json { render :json => res }
		end

	end
end
