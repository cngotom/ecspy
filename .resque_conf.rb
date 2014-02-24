require 'resque/plugins/job_stats'
require 'resque-job-stats/server'

ResqueAddr = "117.121.25.135"
Resque.redis = "#{ResqueAddr}:6379"

module Crawler
class ItemList
	extend Resque::Plugins::JobStats
end

class ItemSales
	extend Resque::Plugins::JobStats
end
end

