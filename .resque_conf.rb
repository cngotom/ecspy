require 'resque/plugins/job_stats'
require 'resque-job-stats/server'

ResqueAddr = "127.0.0.1"
Resque.redis = "#{ResqueAddr}:6379"

module Crawler
class ItemList
	extend Resque::Plugins::JobStats
end

class ItemSales
	extend Resque::Plugins::JobStats
end



class Keyword
	extend Resque::Plugins::JobStats
end

class ZTC
	extend Resque::Plugins::JobStats
end


end

