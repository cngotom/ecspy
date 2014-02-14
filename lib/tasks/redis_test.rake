require 'redis'
require 'redis-lock'
require 'json'

desc "test redis"

task :redis_lock do

	timeout = 10 # measured in seconds
	max_attempts = 100 # number of times the action will attempt to lock the key before raising an exception

	$redis = Redis.new
	$redis.lock_for_update('beers_on_the_wall') do
		puts 'accure'
	    $redis.multi do
	        $redis.set('sing', 'take one down, pass it around.')
	        $redis.decr('beers_on_the_wall')
	    end
	    sleep 10
	end


end


task :redis_pub do

	$redis = Redis.new
	data = {"user" => 'guotao'}

	11000.times do
	  #msg = STDIN.gets
	  #$redis.publish 'channel', data.merge('msg' => msg.strip).to_json

	  $redis.publish 'channel', '1'*100000
	end

end

task :redis_sub do

	$redis = Redis.new(:timeout => 0)
	index = 0

	beg = Time.now
	$redis.subscribe('channel', 'ruby-lang') do |on|
	  on.message do |channel, msg|
	   # data = JSON.parse(msg)
	    #puts "##{channel} - [#{data['user']}]: #{data['msg']}"

	    index += 1

	    if index > 10000
	   		puts Time.now - beg
	   		exit
	   	end


	  end
	end



end
