class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name


  acts_as_follower


  has_many :keywords,:class_name => ShopKeyword,:dependent => :destroy


  #has_many :keyword_records, through: :keywords, :source => :records ,select: 'keyword,user_id,rank,item_id,shop_id,shop_keyword_records.created_at as created_at'
end
