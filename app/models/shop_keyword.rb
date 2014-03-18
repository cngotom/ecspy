#encoding:utf-8
require 'resque'
require 'tasks/crawler'
class ShopKeyword < ActiveRecord::Base
  # attr_accessible :title, :body
 	attr_accessible :shops,:keyword,:user_id
	validates_presence_of :shops,:message => "至少应选择一个店铺"
	validates_presence_of :keyword
	validates_presence_of :user_id


	has_many :records,:class_name => ShopKeywordRecord,:dependent => :destroy


	after_create :enque_job



	private 
	def enque_job
		Resque.enqueue( Crawler::Keyword,id,keyword)  rescue nil
	end



end
