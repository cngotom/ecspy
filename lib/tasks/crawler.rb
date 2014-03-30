require 'redis'
require 'resque'
require 'ostruct'


ResqueAddr = "127.0.0.1"
Resque.redis = "#{ResqueAddr}:6379"

module Crawler

	 

	ScriptDir = File.join(Rails.root,'lib','tasks','phantomjs-script')

	GetListScript = File.join(ScriptDir,'getlist.js')


	Exec = 'phantomjs  --load-images=no'
	ExecTB = 'phantomjs --load-images=yes'
	SlimerJS= 'slimerjs '
	Debug = '--debug=yes'

	GetListLog = "log/phantomjs/getlist.log"
	GetListRes = "log/phantomjs/getlist.res"


	GetSalesLog  = "log/phantomjs/getsales_#{Process.pid}.log"
	GetSalesRes = "log/phantomjs/getsales.res"


	GetKeywordRes = "log/phantomjs/getkeyword.res"
	GetKeywordLog = "log/phantomjs/getkeyword.log"


	GetZTCRes = "log/phantomjs/getztc.res"
	GetZTCLog = "log/phantomjs/getztc.log"


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

			'killed because timeout'
		end
	end



	class ItemListRedis



		def initialize(config = {})
			default_config = {
				:host => "127.0.0.1",
				:port => 6379
			}
			config.merge! default_config
			@redis = Redis.new(:host => ResqueAddr, :port => 6379)
			@redis_key = config[:key]
		end


		def add(data)
			@redis.lpush @redis_key ,data
		end


		def pop()
			@redis.LPOP  @redis_key
		end

		def size 
			@redis.llen @redis_key
		end


		def close

			@redis.quit
		end

		 def self.size
                list_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemList')

                sales_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemSales')

                closed_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemClosed')

                content_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemContent')

                keyword_redis_client =  Crawler::ItemListRedis.new(:key => 'RedisKeyword')

                list_redis_client.size + sales_redis_client.size + closed_redis_client.size+ content_redis_client.size + keyword_redis_client.size
        end

		def self.merged?

			list_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemList')

			sales_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemSales')

			closed_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemClosed')

			content_redis_client = Crawler::ItemListRedis.new(:key => 'RedisItemContent')


			# puts list_redis_client.size
			# puts sales_redis_client.size 
			# puts  closed_redis_client.size
			# puts content_redis_client.size

			list_redis_client.size == 0 && sales_redis_client.size == 0 && closed_redis_client.size == 0 && content_redis_client.size == 0 

		end


	end





	class ItemList
		extend Resque::Plugins::JobStats
		@queue = 'itemlist'

		def self.perform(id,url)


			out_file_ext = Time.new.strftime('.%Y-%m-%d-%H-%M')

			#process-safe file
			out_file = "#{GetListRes}-#{Process.pid}#{out_file_ext}"

			File.delete out_file if File.exist?(out_file)

			run_exe = "#{Exec} #{ScriptDir}/getlist.js #{url} #{id} #{out_file} #{GetListLog}"

			puts run_exe
			retn = exec_with_timeout(run_exe)
			# => retn = 'ok'
			if retn.chomp == 'ok'
				puts 'execute ok'

				list_redis_client = ItemListRedis.new(:key => 'RedisItemList')
				open(out_file) do |out|
					out.each_line do |line|
						list_redis_client.add line
					end
				end
			end
			File.delete out_file if File.exist?(out_file)
			list_redis_client.close
			if retn.chomp != 'ok'
				raise 'error'
			end
		end

	end



	class ItemSales
		extend Resque::Plugins::JobStats
		@queue = 'itemsales'


		def self.perform(item)
			sales_redis_client = ItemListRedis.new(:key => 'RedisItemSales')
			content_redis_client = ItemListRedis.new(:key => 'RedisItemContent')
			closed_redis_client = ItemListRedis.new(:key => 'RedisItemClosed')


			item = OpenStruct.new item
			puts "#{item.title},last_check_time: #{item.last_check_time if item.last_check_time}"

			out_file_ext = Time.new.strftime('.%Y-%m-%d-%H-%M')

			#process-safe file
			out_file = "#{GetSalesRes}-#{Process.pid}#{out_file_ext}"

			timestamp  = item.timestamp
			if item.tmall?
				run_exe  = "#{Exec} #{ScriptDir}/getitem.js #{item.item_sn} #{timestamp} #{out_file} #{GetSalesLog}"
				puts run_exe
				retn = exec_with_timeout run_exe
			else
				run_exe = "#{ExecTB} #{ScriptDir}/getitem_tb.js #{item.item_sn} #{timestamp} #{out_file} #{GetSalesLog}"
				puts run_exe
				retn = exec_with_timeout run_exe
			end	

			if retn.chomp == 'ok'
				puts 'execute ok'

				if File.exist?(out_file)
					open(out_file) do |out|
						index = 0
						out.each_line do |line|	
							if index == 0
								line = JSON.parse(line)
								line['id'] = item.id
								content_redis_client.add line.to_json
							else
								#first line is description
								line = JSON.parse(line)
								line['id'] = item.id
								sales_redis_client.add line.to_json
							end
							index += 1
						end
					end
				end

			elsif retn.chomp == 'closed'

				puts "item: #{item.id} closed"

				closed_redis_client.add ({'id' => item.id }.to_json)

			end


			File.delete out_file if File.exist?(out_file)
			sales_redis_client.close
			content_redis_client.close
			closed_redis_client.close

			if retn.chomp != 'closed' && retn.chomp != 'ok'
				puts retn
				raise retn
			end

			

		end

	end



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


	class Keyword
		extend Resque::Plugins::JobStats
		@queue = 'keyword'

		def self.perform(id,keyword)
			out_file_ext = Time.new.strftime('.%Y-%m-%d-%H-%M')

			#process-safe file
			out_file = "#{GetKeywordRes}-#{Process.pid}#{out_file_ext}"

			File.delete out_file if File.exist?(out_file)

			keyword.extend GBKConvert

			run_exe = "#{Exec} #{ScriptDir}/getsearch.js #{id} #{keyword.to_gbk} #{out_file} #{GetKeywordLog}"

			puts run_exe
			retn = exec_with_timeout(run_exe)
			# => retn = 'ok'
			if retn.chomp == 'ok'
				puts 'execute ok'

				keyword_redis_client = ItemListRedis.new(:key => 'RedisKeyword')
				open(out_file) do |out|
					keyword_redis_client.add out.read
				end

				keyword_redis_client.close
			end
			File.delete out_file if File.exist?(out_file)
			if retn.chomp != 'ok'
				raise 'error'
			end

		end

	end


	class ZTC
		extend Crawler
		extend Resque::Plugins::JobStats
		
		RedisKey = 'RedisZTCKey'
		@queue='ztc'


		def self.redis
			@redis ||= Redis.new(:host => ResqueAddr, :port => 6379)

		end


		def self.get_ztc_list(key)
			out_file_ext = Time.new.strftime('.%Y-%m-%d-%H-%M')
			out_file = "#{GetZTCRes}-#{Process.pid}#{out_file_ext}"


			key.extend GBKConvert
			run_exe = "#{Exec} #{ScriptDir}/getztc.js #{key.to_gbk}  #{out_file} #{GetZTCLog}"

			puts run_exe
			retn = exec_with_timeout(run_exe)
			
			if retn.chomp == 'ok'
				puts 'execute ok'
				if File.exist?(out_file)
					res = open(out_file).read
				end
			end

			File.delete out_file if File.exist?(out_file)
			res
		end


		def self.get_job_list
			redis.lrange RedisKey,0,-1
		end


		def self.generate_jobs(arr)
			#save count
			arr = arr.dup
			count = arr['count'].to_i


			#save job id
			start = redis.llen RedisKey
			arr['id'] = start.to_i
			arr['time'] = Time.now
			redis.lpush RedisKey,JSON.generate(arr)

			#init
			redis.set "#{RedisKey}:#{arr['id']}",0

			arr.delete 'count'
			arr.delete 'time'
			#generate jobs
			count.times do |i|
				Resque.enqueue(Crawler::ZTC,arr)
			end

		end

		def self.get_job_done_count(id)
			res = redis.get "#{RedisKey}:#{id}"
			res.to_i
		end


		def self.clear_all
			redis.del RedisKey
			Resque::Job.destroy(@queue, self.name)
		end

		# def self.after_enqueue(keyword,item_id,proxy)
		# 	puts 'after enque'
		# end


		def self.perform(arr)
			keyword = arr['keyword']
			item_id = arr['item_id']
			proxy = arr['proxy']
			proxystr = ''
			proxystr = " --proxy-type=http --proxy=#{proxy}" if proxy
 
			keyword.extend GBKConvert
			keyword.to_gbk

			run_exe = "#{Exec}  #{proxystr} #{ScriptDir}/clickztc.js #{keyword.to_gbk} #{item_id} #{GetZTCLog} #{GetZTCLog}"#no need outfile 
			puts run_exe
			retn = exec_with_timeout(run_exe)

			puts retn
		end




		def self.after_perform(arr)#id,keyword,item_id,proxy)
			redis.incr "#{RedisKey}:#{arr['id']}"
		end
	end


end