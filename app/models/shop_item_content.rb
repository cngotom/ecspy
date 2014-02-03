require 'nokogiri'

class ShopItemContent < ActiveRecord::Base

	acts_as_versioned

	attr_accessible :content
	self.non_versioned_columns << 'shop_item_id' 


	belongs_to :shop_item




	def update_if_changed(cont)
		is_content_changed =  !self.class.compare(self.content,cont) 

		if is_content_changed
			self.content = cont
			save
		else
			false
		end

	end



	COLLECT_SRC_PROC = proc do |doc,collect|
			doc.css('img').each do |img|
					src = img['src']
					src = img['data-ks-lazyload'] if  img['data-ks-lazyload']
					collect[src] = true
			end
	end


	def self.compare(ca,cb)
		doca = Nokogiri::HTML(ca)

		docb = Nokogiri::HTML(cb)

		# 对比文字
		res = (doca.text  == docb.text)
		# 对比图片
		seta = {}
		setb = {}
		COLLECT_SRC_PROC.call(doca,seta)
		COLLECT_SRC_PROC.call(docb,setb)
		res &= ( seta == setb)
	end

end
