require 'spec_helper'

describe ShopItemContent do

  it "should not be saved if content not changed" do

  	cont = nil

  	expect {
  		cont = ShopItemContent.create(:content => 'before') 


  	}.to change(ShopItemContent,:count).by(1)


	cont2 = ShopItemContent.create(:content => 'before') 
  	cont2.update_if_changed('before')


  	expect(cont2.content_changed?).not_to be_true
  	#cont.should_not content_changed?

  end



  it "should saved versions if content changed" do  
  	cont = nil



  	cont = ShopItemContent.create(:content => 'before') 


  	expect {

	  	cont.update_if_changed('after')

	  	expect(cont.content).to eq('after')


  	}.to change(cont,:version).by(1)

  end



  it "create new shop_item_content if not exists" do 

		item = ShopItem.create()

		expect(item.content).to be_false

		cont = item.create_content	

		expect(cont.shop_item_id).to eq(item.id)

  end


  it "should changed update_time if changed" do


  end



end


