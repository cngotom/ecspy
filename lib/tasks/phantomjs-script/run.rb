#encoding:utf-8
require 'timeout'
require 'open-uri'
require 'net/http'
def loop_run 
	while true
		yield rescue puts $!
	end
end


def exec_with_timeout(cmd,timeout = 60,max_retry = 0)
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
		false
	end
end



ItemID = 15972071484 
Keyword = '黄瓜籽粉'
Proxy='221.202.130.207:8088'
IpCheck = 'http://www.365store.cn/getip.php'
GetProxyUrl = 'http://api.iphai.com/getapi.ashx?ddh=590377951187596&num=1&yys=1&am=3&guolv=y&mt=0&fm=text'




def text_proxy(count)
	count.times do
		proxy = open(GetProxyUrl).read.chomp
		puts proxy if valide_proxy2(proxy.split(':')[0],proxy.split(':')[1].to_i)
	end
end

def valide_proxy(proxy)
	begin
		res=nil
		run  = "slimerjs  --proxy-type=http --proxy=#{proxy} geturl.js #{IpCheck}"
		Timeout.timeout(3) do
			res =`#{run}`
		end
		true if proxy.start_with? res.chomp
	rescue Timeout::Error
		false
	rescue
		puts $!
		false
	end
end

def valide_proxy2(host,port)
	web_proxy = Net::HTTP::Proxy(host, port)
	url = URI.parse('http://m.taobao.com/')

	begin
		Timeout.timeout(3) do
			beg = Time.new
			web_proxy.start(url.host, url.port) do |http|
			  req = Net::HTTP::Get.new(url.path)
			  res = http.request(req) #.body
			  diff = Time.new - beg 
			  puts diff
			  res.code.to_i == 200 && diff < 1
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


if ARGV[0] == '-t'
	text_proxy 10
	exit
end



def work 
	#First step:Get ip
	proxy = open(GetProxyUrl).read.chomp
	#Second steo:Valide ip addr
	host = proxy.split(':')[0]
	port = proxy.split(':')[1].to_i
	if valide_proxy2(host,port)
		puts "use proxy: #{proxy}"
		4.times do 
			run = "slimerjs --load-images=no  --proxy-type=http --proxy=#{proxy}  clickztc.js #{Keyword} #{ItemID} a.out a.res"
			puts run
			res = exec_with_timeout(run)
			puts res
			break unless res
		end

	end

end

loop_run do 
	work
end

# loop_run do
# 	run = "slimerjs --load-images=no  --proxy-type=http --proxy=#{Proxy}  clickztc.js #{Keyword} #{ItemID} a.out a.res"
# 	puts run
# 	puts `#{run}`
# end
