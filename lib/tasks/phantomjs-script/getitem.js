system = require('system')
pageext = require("./lib/pageext.js")


var args = system.args;
var Args = {};
var page 

if (args.length != 5) {
  console.log('useage:phantomjs getitem.js <item_sn> <start timestamp> <outfile> <logfile>');
  phantom.exit();

} else {
 	Args.item_sn = args[1];
 	Args.start_time = args[2];
 	Args.outfile = args[3];
 	Args.logfile = args[4];
}




function init()
{
	page = pageext.create({LogFile:Args.logfile,ResFile:Args.outfile});

	//check if the item is closed
	setTimeout(function(){
		if(page.url.indexOf('http://detail.tmall.com/auction/noitem.htm') == 0)
		{
			 page.Print('closed');
			 phantom.exit();
		}	
	},5000);
	page.Log('Start item :' + Args.item_sn);
}




function visitItem(url)
{

	page.open(url, function(status) {
		     page.Log('pageStart');
         pageext.addUtils(page)
			 	 page.evaluate( "function(){  window.start_time = " +  Args.start_time +" ; window.check_time = parseInt(new Date().getTime() /1000) }");

			 	 page.evaluate(function() {
			 	 		//window.scroll(0,$('body')[0].offsetHeight);
			 	 		//in case of work computer time is changed
			 	 		if( window.start_time  >  window.check_time  + 3600)
			 	 		{
			 	 			console.log("Warning: last_check_time is: " + window.start_time + " but now is "+ window.check_time );
			 	 			window.check_time = window.start_time;
			 	 		}

			 	 		WaitUntil(
				 	 		function(){
				 	 			$('#description>div.content img').each(function(index,ele)
				 	 			{
									if($(ele).attr('data-ks-lazyload'))
									{
										return false;
									}
				 	 			});
								console.log($('#J_TabBar li:eq(2) a').html());
								console.log($('#description>div.content').html().trim())

				 	 			return $('#J_TabBar li:eq(2) a').html() != undefined && $('#description>div.content').html().trim()!='描述加载中';		
				 	 		},

				 	 	
				 	 		function(){
				 	 			//输出产品信息
				 	 			// var title = $('.tb-detail-hd h3').text().trim();
				 	 			// var desc = $('.tb-detail-hd p').text().trim();

				 	 			// //getprice
				 	 			// var price = 1000000000; //very big
				 	 			// WaiUntil(function(){ return $('.tm-price')},
				 	 			// function(){
				 	 			// 	$('.tm-price').each(function(index,ele){
				 	 			// 		var nowprice =  parseFloat($(ele).text());
				 	 			// 		//console.log("nowprice: " + nowprice);	
				 	 			// 		if(price > nowprice)
				 	 			// 			price = nowprice;

				 	 			// 	});
				 	 			// });


			 	 				// console.log("title: " + title);
			 	 				// console.log("desc: " + desc);
			 	 				// console.log("price: " + price);
			 	 				var pos = getElementAbsPos($('#J_showBuyerList')[0]);
			 	 				//window.scroll(pos.left,pos.top);
                dispatch($('#J_TabBar a')[2],"click");
				 	 			var link = $('#J_TabBar li:eq(2) a')[0];

				 	 			console.log("J_showBuyerList is " + link.innerHTML);
    							dispatch(link, "click");

    							var output = '';

								var g_firstSale = true; 


    							function getNext(page)
    							{

    								if(page >= 20) {
    									window.callPhantom(output);
    									alert('close');

    								}
    								else {

    									function handle()  {
    										console.log('start page :' + page);

			    								$('#J_showBuyerList tr:gt(0)').each(function(indexi,tr) {
			    									 /* iterate through array or object */

			    									 var line = '';

			    									 var tds = $(tr).find('td');

			    									 var data  = {};
			    										
			    									
			    									
			    									data = {
			    									 	'user_name' : tds[0].innerText.trim(),

			    									 	'item_price' : parseFloat(tds[3].innerText.replace('¥','')),
 
			    									 	'item_num' : parseInt(tds[2].innerText),

			    									 	'buy_time' : tds[4].innerText,
			    									 }

			    									 if(g_firstSale)
			    									 {
			    									 	g_firstSale = false;

			    									 	data['last_check_time'] = window.check_time;

			    									 }
			    									
			    									 var current_timestamp = strtotime(data['buy_time']);

			    									 console.log(data['buy_time']);
			    									 console.log("current: " + current_timestamp );
			    									 console.log("start_time: " + window.start_time );
			    									if( current_timestamp <  window.start_time)
			    									{
			    										window.callPhantom(output);
			    										alert('close');
			    									}


			    									output = output + JSON.stringify(data)  + "\n";




			    								


			    								});

			    								var nowTrValue = $('#J_showBuyerList tr:eq(1)').html();

			    								var link = $('.pagination a:last')[0];
			    								if(!link || link.innerHTML.indexOf('下一页') ==-1)
			    								{
			    									window.callPhantom(output);
			    									alert('close');
			    								}
			    								dispatch(link, "click");

			    								WaitUntil(function(){

			    									var currentValue = $('#J_showBuyerList tr:eq(1)').html();
			    									if(nowTrValue == currentValue)
			    										return false;
			    									else{
			    										nowTrValue = currentValue;
			    										return true;
			    									}

			    								},
			    								function(){getNext(page + 1)});


    									}




    									if(page == 0)
    									{


    										//save content
											var content = $('#description').html();

		    								//handle \n
		    								content = content.replace(/\n/g,'');

		    								var first_line_data = {
		    									'content' : content,
		    									'last_check_time' : window.check_time
		    								}

		    								window.callPhantom(  JSON.stringify( first_line_data )+ "\n"); //first line is content



		    								//tmall .J_TDealCount.tm-MRswitchRecord
    										if(parseInt( $('.J_TDealCount').html()) >0) {

	    										WaitUntil(function(){
	    											var pos = getElementAbsPos($('#J_showBuyerList')[0]);
			 	 									//window.scroll(pos.left,pos.top);
                          dispatch($('#J_TabBar a')[2],"click");

	    											return $('#J_showBuyerList tr').length > 0

	    										}
			    							,handle);
	    									
	    									}

			    							else{
			    								window.callPhantom(output);
			    								alert('close');
			    							}
	    								}
			    						else
			    							handle();
    								}

    								
    							}
    							getNext(0);

				 	 			

				 	 		}
				 	 	);

	 	 });

});
}





init();
//page.open('http://www.tmall.com',function(){
	visitItem('http://detail.tmall.com/item.htm?id='+Args.item_sn);
//});






