require 'redis'
class FileUploadController < ApplicationController
  layout false
  
  def index
  end

  def upload
  	res = {}

  	res['type'] = params[:type]
  	res['id'] = params[:id]
  	res['data'] = params[:data].read


  	$redis = Redis.new

  	$redis.publish 'ecspy-list_data',res.to_json

  	render text:'ok'

  end
end
