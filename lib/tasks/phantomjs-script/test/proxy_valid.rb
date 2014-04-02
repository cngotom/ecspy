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



IpCheck = 'http://www.365store.cn/getip.php'
GetProxyUrl = 'http://api.iphai.com/getapi.ashx?ddh=590377951187596&num=1&yys=1&am=3&guolv=y&mt=0&fm=text'




def valide_proxy(host,port)
	web_proxy = Net::HTTP::Proxy(host, port)
	url = URI.parse('http://www.taobao.com/')

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

def test_proxy
	check_list = %w[
		112.124.38.83:8088
		115.29.178.232:8088
		115.29.167.86:8088
		121.199.61.96:8088
		115.29.178.235:8088
		202.98.1.218:8080
		115.29.184.139:8088
		115.29.178.231:8088
		119.188.46.42:8080
		183.60.46.72:8080
		115.238.166.251:80
		61.178.73.22:7686
		121.199.62.105:8088
		115.238.166.252:80
		183.60.81.104:80
		112.124.41.71:8088
		117.25.129.238:8888
		112.124.39.177:8088
		60.222.224.135:8888
		221.176.14.72:80
		116.55.242.164:80
		113.108.78.114:80
		218.9.69.2:8080
		139.210.98.86:8080
		114.80.136.112:7780
		116.112.66.102:808
		122.136.46.151:80
		183.207.228.14:85
		222.87.129.29:80
		42.121.105.155:8888
		112.90.59.8:8080
		27.13.249.91:8088
	]

	check_list.each do |proxy|
		puts proxy
		host = proxy.split(':')[0]
		port = proxy.split(':')[1].to_i
			
		valide_proxy(host,port)

	end

end

if ARGV[0] == '-t'
	test_proxy 
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