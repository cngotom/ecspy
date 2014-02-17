class ShopItemContentVersion < ActiveRecord::Base

	belongs_to :shop_item_content


	def self.today_changes(shop,offset = 0)
		ShopItemContentVersion.includes(:shop_item_content=>{:shop_item=>:shop}).where(['shops.id= ? and (shop_item_content_versions.updated_at > ? and shop_item_content_versions.updated_at < ? )',shop, Time.new.beginning_of_day-offset*3600*24,Time.now.end_of_day-offset*3600*24])
	end


	before_save :unsurport
	before_update :unsurport

	def unsurport
		raise 'unsurport for Versions model'
	end
	def delete
		raise 'unsurport for Versions model'
	end
	def delete!
		raise 'unsurport for Versions model'
	end

	def self.delete
		raise 'unsurport for Versions model'
	end
	def self.delete!
		raise 'unsurport for Versions model'
	end

end