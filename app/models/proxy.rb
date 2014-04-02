require 'open-uri'
class Proxy < ActiveRecord::Base
  # attr_accessible :title, :body
 # GetProxyUrl = 'http://api.iphai.com/getapi.ashx?ddh=590377951187596&num=1&yys=1&am=3&guolv=y&mt=0&fm=text'

  GetProxyUrl = 'http://www.phone600.com/getapi.ashx?ddh=599029779147596&num=1&yys=1&am=3&guolv=y&mt=6&fm=text'
  def self.get_proxy
  	
  	max = 10

  	max.times do  
  		proxy = open(GetProxyUrl).read.chomp

  		res = valide_proxy(proxy)
  		if res 
  			res2 = valide_proxy2(proxy)
  			if res2
  				create(:addr=>proxy,:timeout=>res)
  				return proxy
  			else
  				next
  			end
  		else
  			puts "#{proxy} faild"
  			next
  		end

  	end
  	false
  end


  private
	def self.valide_proxy(proxy)
		proxy = proxy.split(':')
		host = proxy[0]
		port = proxy[1].to_i
		web_proxy = Net::HTTP::Proxy(host, port)
		url = URI.parse('http://www.taobao.com/')
		begin
			Timeout.timeout(1) do
				web_proxy.start(url.host, url.port) do |http|
				  beg = Time.new
				  req = Net::HTTP::Get.new(url.path)
				  res = http.request(req) #.body
				  diff = Time.new - beg 
				  if res.code.to_i == 200 && diff < 1
				  	diff
				  else
				  	false
				  end
				end
			end
		rescue Timeout::Error
			false
		rescue
			puts $!
			false
		end
	end


	def self.valide_proxy2(proxy)
		begin
			Timeout.timeout(10) do
				run  = "phantomjs --load-images=no  --proxy-type=http --proxy=#{proxy} lib/tasks/phantomjs-script/getztc.js abc log/phantomjs/a.out log/phantomjs/a.res"
				puts run
				res = `#{run}`
				puts res
				res.chomp == 'ok'
			end
		rescue Timeout::Error
			false
		rescue
			puts $!
			false
		end
	end
end
