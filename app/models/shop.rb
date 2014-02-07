class Shop < ActiveRecord::Base
	attr_accessible :title,:url,:goods_num

	validates_presence_of :url,:title
	validates_uniqueness_of :url

	acts_as_followable

	has_many :shop_items

	#not update in 6 hours or created in 6 hours
	scope :recently_not_updated,where( ["updated_at < ? or ( created_at > ?  and updated_at = created_at )", Time.now - 6.hour, Time.now - 6.hour])

	#scope :unwatched, lamda {|user|  self.ALl - User.find(user).followed  }

	def touch
		if !new_record?
			update_attribute(:updated_at,Time.new);
		end
	end




	def today_sales_count(offset = 0)
		shop_items.inject(0) {|sum,item|
			puts " #{item.id} #{item.title} #{item.today_sales_count}"
			
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
		where(['id not in (?)', watched_ids ])

	end


	def self.watched(user)
		watched = User.find(user).following_by_type(self.name)
	end

end
