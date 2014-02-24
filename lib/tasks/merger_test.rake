require 'redis'
require 'redis-lock'

desc "merge all the data get from distributions"

task :merged => :environment do 

	$redis = Redis.new(:timeout => 0)

	$redis.subscribe('ecspy-command', 'ecspy-list_data','ecspy-item_data') do |on|
	  on.message do |channel, msg|

	  	if channel == 'ecspy-list_data'

	  		puts 'list_data ' + msg

	  	elsif channel == 'item_data'

	  		puts 'ecspy-item_data ' + msg.size.to_s

	  	else channel == 'ecspy-command'

	  		exit
	  	end

	   
	  end
	end


	
end