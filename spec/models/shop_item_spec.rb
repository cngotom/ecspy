#encoding:utf-8
require 'spec_helper'

describe ShopItem do

  it "should change price if price changed over 0.01" do


  	item = ShopItem.create(:price => 1.0) 


  	expect {


	  	expect(item.update_if_changed({"price"=>0.96})).to eq(false)

	  	expect(item.price).to eq(1.0)


  	}.to change(item,:version).by(0)


  	expect {

	  	item.update_if_changed({"price"=>0.59})

	  	expect(item.price).to eq(0.59)


  	}.to change(item,:version).by(1)


  end



  it "should not  be saved as new version ,if only thumb format is changed" do


    item = ShopItem.create(:thumb => 'http://img01.taobaocdn.com/bao/uploaded/i4/15443032304271935/T1_mc0Fc0aXXXXXXXX_!!0-item_pic.jpg_180x180.jpg') 


    expect {


      item.update_if_changed({"thumb"=>'http://img01.taobaocdn.com/bao/uploaded/i4/15443032304271935/T1_mc0Fc0aXXXXXXXX_!!0-item_pic.jpg_80x80.jpg'})

      expect(item.thumb).to eq('http://img01.taobaocdn.com/bao/uploaded/i4/15443032304271935/T1_mc0Fc0aXXXXXXXX_!!0-item_pic.jpg_180x180.jpg')


    }.to change(item,:version).by(0)


    expect {

     expect( item.update_if_changed({"thumb"=>'http://img01.taobaocdn.com/bao/uploaded/i4/15443032304271935/T1_mc0Fc0aXXXXXXXX_!!0-item_pic.png_80x80.jpg'})).to eq(true)

      expect(item.thumb).to eq('http://img01.taobaocdn.com/bao/uploaded/i4/15443032304271935/T1_mc0Fc0aXXXXXXXX_!!0-item_pic.png_80x80.jpg')


    }.to change(item,:version).by(1)


  end


 end