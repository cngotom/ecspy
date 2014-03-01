#encoding:utf-8
require 'spec_helper'

describe ShopItem do

  it "should change price if price changed over 0.01" do


  	item = ShopItem.create(:price => 1.0) 


  	expect {


	  	item.update_if_changed({"price"=>0.99})

	  	expect(item.price).to eq(1.0)


  	}.to change(item,:version).by(0)


  	expect {

	  	item.update_if_changed({"price"=>0.59})

	  	expect(item.price).to eq(0.59)


  	}.to change(item,:version).by(1)


  end




 end