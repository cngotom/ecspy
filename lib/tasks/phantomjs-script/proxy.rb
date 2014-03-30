#encoding:utf-8
require 'open-uri'
require 'json'
require 'net/http'
require 'timeout'

APIKEY = '31132dcedcfc2617425eaeec'

Site = "http://letushide.com/fpapi/?key=#{APIKEY}&ps=http&cs=us"
res = JSON.parse open(Site).read



def exec_with_timeout(cmd,timeout = 20,max_retry = 0)
	begin
		pipe = IO.popen(cmd)
		Timeout.timeout(timeout) do
			pipe.read
		end
	rescue Timeout::Error
		puts "#{cmd} time out "
		Process.kill 9, pipe.pid
		max_retry -= 1
		retry if max_retry >= 0 

		'killed because timeout'
	end
end


def valide_proxy(host,port)

	web_proxy = Net::HTTP::Proxy(host, port)
	url = URI.parse('http://m.taobao.com/')

	begin
		Timeout.timeout(10) do
			web_proxy.start(url.host, url.port) do |http|
			  req = Net::HTTP::Get.new(url.path)
			  res = http.request(req) #.body
			  res.code.to_i == 200
			 # res[0,res.index('Array')] == host
			 # true
			end
		end
	rescue Timeout::Error
		false
	rescue
		puts $!
		false
	end

	

end



if res['status'] == 0

	res['data'].each do |r|
		host = r['host']
		port = r['port']
		puts "begin test #{host}"
		if valide_proxy(host,port)
			puts "#{host} #{port} OK" 
			3.times do 
				run = "slimerjs --proxy-type=http --proxy=#{host}:#{port} --load-images=no clickztc.js 黄瓜籽粉 15972071484  a.out a.log"
				puts run
				puts exec_with_timeout(run)
			end
		end
	end
end







