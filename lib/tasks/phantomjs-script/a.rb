#coding: utf-8
str = "黄瓜籽粉 补钙"

module GBKConvert
	def to_gbk
		gbk = self.encode("GBK","utf-8")
		s = ''
		gbk.bytes.each {|b|
			s << "%#{b.to_s(16).upcase}"
		}
		s
	end
	
end


str.extend GBKConvert

puts str.to_gbk

puts "phantomjs  getztc.js #{str.to_gbk} a.out a.log"
puts `phantomjs  getztc.js #{str.to_gbk} a.out a.log`
