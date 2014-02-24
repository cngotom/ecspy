require 'redis'
require 'ostruct'


ResqueAddr = "117.121.25.135"
Resque.redis = "#{ResqueAddr}:6379"

module Crawler

	 

	ScriptDir = File.join(Rails.root,'lib','tasks','phantomjs-script')

	GetListScript = File.join(ScriptDir,'getlist.js')


	Exec = 'phantomjs  --load-images=no'
	ExecTB = 'phantomjs --load-images=yes'
	Debug = '--debug=yes'

	GetListLog = "log/phantomjs/getlist.log"
	GetListRes = "log/phantomjs/getlist.res"


	GetSalesLog  = "log/phantomjs/getsales.log"
	GetSalesRes = "log/phantomjs/getsales.res"

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
			@redis = Redis.new(config[:host] => ResqueAddr, config[:port] => 6380)
			@redis_key = config[:key]
		end


		def add(data)
			@redis.lpush @redis_key ,data
		end


		def pop()
			@redis.LPOP  @redis_key
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
				run_exe  = "#{Exec} #{ScriptDir}/getitem.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}"
				puts run_exe
				retn = exec_with_timeout run_exe
			else
				run_exe = "#{ExecTB} #{ScriptDir}/getitem_tb.js #{item.item_sn} #{timestamp} #{GetSalesRes} #{GetSalesLog}"
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
								content_redis_client.add({'id' => item.id,'content' => line}.to_json)
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

				File.delete out_file if File.exist?(out_file)
			elsif retn.chomp == 'closed'

				puts "item: #{item.id} closed"

				closed_redis_client.add ({'id' => item.id }.to_json)

				File.delete out_file if File.exist?(out_file)
			else
				puts retn
				File.delete out_file if File.exist?(out_file)
				raise 'error'
			end

		end

	end


end