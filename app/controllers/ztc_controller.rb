#encoding:utf-8
require 'tasks/crawler'
class ZtcController < ApplicationController
  before_filter :authenticate_user!
  layout 'smart_admin'

  
  def check
  	 respond_to do |format|
      format.html
      format.json {
      	 retn = Crawler::ZTC.get_ztc_list(params[:keyword])
         render  :text => retn
      }
    end
  end


  def save 

      arr = {
        'keyword' => params['keyword'],
        'count' => params['count'].to_i,
      }
      arr['proxy'] = params['proxy'] if params['proxy'] =~ /\d+/


      items = params["items"]

      items.each do |item|
          puts item
          arr['item_id'] = item.chomp
          Crawler::ZTC.generate_jobs(arr)
      end

      flash[:notice] = '任务创建成功'
      redirect_to :action => :status

  end


  def status
    jobs_list = Crawler::ZTC.get_job_list
    @jobs_list = []
    jobs_list.each do  |job|
      job = JSON.parse(job)
      @jobs_list << job.merge('done' =>  Crawler::ZTC.get_job_done_count(job['id']))
    end

  end

  def clear
      Crawler::ZTC.clear_all
      flash[:notice] = '任务清理成功'
      redirect_to :action => :status
  end

end
