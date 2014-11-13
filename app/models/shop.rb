#encoding:utf-8
class Shop < ActiveRecord::Base
	attr_accessible :title,:url,:goods_num, :disabled

	validates_presence_of :url,:title
	validates_uniqueness_of :url

	acts_as_followable

	has_many :shop_items ,:dependent => :destroy

	has_many :shop_contents, :through => :shop_items,:source => :content

	#not update in 6 hours or created in 6 hours
	scope :recently_not_updated,where( ["updated_at < ? or ( created_at > ?  and updated_at = created_at )", Time.now - 12.hour, Time.now - 12.hour])

	#scope :unwatched, lamda {|user|  self.ALl - User.find(user).followed  }

	default_scope where(:disabled => 0)

	def touch
		if !new_record?
			update_attribute(:updated_at,Time.new);
		end
	end



	def tmall?
		self.url.index("tmall")
	end


	def today_sales(offset = 0)
		ItemSale.includes(:shop_item,:shop).where(['shops.id= ? and (buy_time > ? and buy_time < ? )',self.id, Time.new.beginning_of_day-offset*3600*24,Time.now.end_of_day-offset*3600*24])
	end


	# def today_sales(offset = 0)
	# 	sum = []
	# 	shop_items.each {|item|
	# 		#puts " #{item.id} #{item.title} #{item.today_sales_money} #{item.today_sales_money}"
	# 		res = item.today_sales(offset)
	# 		sum.concat res if res.count > 0
	# 	}
	# 	sum
	# end


	def today_sales_count(offset = 0)
		shop_items.inject(0) {|sum,item|
			#puts " #{item.id} #{item.title} #{item.today_sales_count}"

			sum + item.today_sales_count(offset)
		}
	end

	def today_sales_money(offset = 0)
		shop_items.inject(0) {|sum,item|
			#puts " #{item.id} #{item.title} #{item.today_sales_money} #{item.today_sales_money}"
			sum + item.today_sales_money(offset)
		}
	end


	def self.unwatched(user)
		watched = User.find(user).following_by_type(self.name)

		watched_ids = []
		watched.each do |w|
			watched_ids << w
		end
		#in case of watche_ids is null
		watched_ids << -1
		where(['id not in (?)', watched_ids ])

	end


	def self.watched(user)
		watched = User.find(user).following_by_type(self.name)
	end


	validate :url_validate
	def url_validate
	    #unless url  =~ /^http:\/\/(\w)*.(tmall|taobao).com\/$/
	    unless url  =~ /^http:\/\/(\w)*.(tmall).com\/$/
	    	errors[:url] << 'url格式不正确 参考 ： http://slwsp.tmall.com/'
	    end
  	end

#
	# before save do
	# 	url << '/' if url.last != '/'
	# end


end
