#encoding:utf-8
class ShopItem < ActiveRecord::Base

	belongs_to :shop

	has_many :item_sales,:dependent => :destroy

	has_one :content,:class_name => ShopItemContent ,:dependent => :destroy



	attr_accessible :title,:desc,:content,:price,:shop_id,:item_sn,:sales_count,:comments_count,:status,:thumb,:last_check_time

	acts_as_versioned :if => Proc.new { |item| item.changed? } do 
		def status_text
			(status==1)? '下架' : '上架'
		end
	end

	VersiondAttr = [:title,:desc,:content,:price,:status,:thumb]

	self.non_versioned_columns << 'shop_id' 
	self.non_versioned_columns << 'item_sn' 
	self.non_versioned_columns << 'comments_count' 
	self.non_versioned_columns << 'sales_count'
	#self.non_versioned_columns << 'status'
	self.non_versioned_columns << 'content'
	self.non_versioned_columns << 'last_check_time'


	scope :recently_not_check ,where(["status = 0 and (last_check_time < ? or ( last_check_time is NULL ))", Time.now - 6.hour])




	class << self

		def find_or_create_by_sn(item_sn)
			res = find_by_item_sn(item_sn)
			res = new(:item_sn => item_sn) unless res
			res
		end

	end






	def changed?
		@changed || false
	end



	def update_status(_status)
		if status != _status
			@changed = true
			update_attributes(:status=>_status)
			@changed = false
		end
	end


	def update_if_changed(data)
		data = data.clone
		is_titile_or_price_changed = ( title != data['title'] ||  price.to_f.round(1) != data['price'].to_f.round(1) ||  ShopItem.thumb_changed?(thumb,data['thumb'])    ) 
		if is_titile_or_price_changed
			@changed = true
			assign_attributes(data)
			save
			@changed = false

		elsif (sales_count != data['sales_count'] ||  comments_count != data['comments_count'] )#|| shop_id!=data['shop_id']) 
			
			data.delete 'title'
			data.delete 'price'
			assign_attributes(data)
			save
		end
		is_titile_or_price_changed
	end


	def touch
		if !new_record?
			update_attribute(:updated_at,Time.new);
		end
	end


	def check
		update_attribute(:last_check_time,Time.new);
	end


	def today_sales(offset = 0)
		item_sales.where(["buy_time > ? and buy_time < ?",Time.new.beginning_of_day-offset*3600*24,Time.now.end_of_day-offset*3600*24])
	end

	def today_sales_count(offset = 0)
		today_sales(offset).inject(0) {|sum,i| sum + 1 }
	end

	def today_sales_money(offset = 0)
		today_sales(offset).inject(0) {|sum,i| sum + i.item_num * (i.item_price ? i.item_price : i.shop_item.price)}

	end

	def status_text
		(status==1)? '下架' : '上架'
	end


	def self.status_text(status)
		(status==1)? '下架' : '上架'
	end

	def self.thumb_changed?(fthumb,sthumb)

		fthumb ||= ''
		sthumb ||= ''
		fmat_reg = /_\d+x\d+\.\w*/
		fthumb.sub(fmat_reg,'') != sthumb.sub(fmat_reg,'')
	end
end


