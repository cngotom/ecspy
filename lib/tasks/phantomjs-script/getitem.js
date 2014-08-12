var page = require('webpage').create();
waitfor = require('./waitfor');
fs = require('fs')
system = require('system')

var args = system.args;

var Args = {};


if (args.length != 5) {

//phantomjs getitem.js 35018792719 1390151959 a.out a.log

  console.log('useage:phantomjs getitem.js <item_sn> <start timestamp> <outfile> <logfile>');
  phantom.exit();

} else {
 
 	Args.item_sn = args[1];

 	Args.start_time = args[2];

 	Args.outfile = args[3];
 	Args.logfile = args[4];


}


log = function(msg)
{
	//fs.write(Args.logfile , msg +  "\n", 'a');

}



function init()
{
	page = require('webpage').create();
	page.settings.resourceTimeout = 20000; // 20 seconds
//	page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.57 Safari/537.36';
	page.onResourceTimeout = function(e) {
	 // console.log(e.errorCode);   // it'll probably be 408 
	  console.log(e.errorString); // it'll probably be 'Network timeout on resource'
	  console.log(e.url);         // the url whose request timed out
	 // phantom.exit(1);
	};

	page.onConsoleMessage = function(msg) {

		log(msg);
	};
	page.onCallback = function(msg)
	{

		fs.write(Args.outfile, msg, 'a');


	}
	page.onAlert = function(msg)
	{
		if(msg  === 'save')
		{
			page.evaluate(function() {
				console.log(jQuery('body').html());
			});
		}
		else if( msg === 'close' )
		{
			 console.log('ok'); //return code
			 phantom.exit();
		}
		else if( msg === 'timeout' )
		{
			 console.log('timeout'); //return code
			 phantom.exit();
		}

		

	};

	page.safeInjectJs = function()
	{



	};
	page.onError = function(msg, trace) {
	  	log("Error:" + msg);
	};



	//check if the item is closed
	setTimeout(function(){
		if(page.url.indexOf('http://detail.tmall.com/auction/noitem.htm') == 0)
		{
			 console.log('closed');
			 phantom.exit();
		}	

	},5000);

	log('Start item :' + Args.item_sn);

}









function visitItem(url)
{

	page.open(url, function(status) {
		log('pageStart');
	//	if ( status === "success" ) {

			 if(page.injectJs("jQuery.min.js"))
			 {
			 	// log('loadJs end');
			 	var height = page.evaluate(
			 		function() {
			 			function getDocHeight() {
						    var D = document;
						    return Math.max(
						        Math.max(D.body.scrollHeight, D.documentElement.scrollHeight),
						        Math.max(D.body.offsetHeight, D.documentElement.offsetHeight),
						        Math.max(D.body.clientHeight, D.documentElement.clientHeight)
						    );
						}
			 			return getDocHeight() /2 ;
			 		}
				 	
				);
			 	 		

			 	 page.scrollPosition = {
			  		top: height,
			  		left: 0
				 };
				 log(height);

				 waitfor.init(page);

			 	 page.evaluate( "function(){  window.start_time = " +  Args.start_time +" ; window.check_time = parseInt(new Date().getTime() /1000) }");


			 	 page.evaluate(function() {

			 	 		//window.scroll(0,$('body')[0].offsetHeight);
			 	 		//in case of work computer time is changed
			 	 		if( window.start_time  >  window.check_time  + 3600)
			 	 		{
			 	 			console.log("Warning: last_check_time is: " + window.start_time + " but now is "+ window.check_time );

			 	 			window.check_time = window.start_time;

			 	 		}

			 	 		WaiUntil(
				 	 		function(){

				 	 			$('#description>div.content img').each(function(index,ele)
				 	 			{

									if($(ele).attr('data-ks-lazyload'))
									{
										return false;
									}
				 	 			});

								console.log($('#J_TabBar li:eq(2) a').html());


				 	 			return $('#J_TabBar li:eq(2) a').html() != undefined && $('#description>div.content').html().trim()!='描述加载中';		
				 	 		},

				 	 	
				 	 		function(){
			 	 					function getElementAbsPos(e) 
									{
									    var t = e.offsetTop;
									    var l = e.offsetLeft;
									    while(e = e.offsetParent)
									    {
									        t += e.offsetTop;
										l += e.offsetLeft;
									    }

									    return {left:l,top:t};
									}

				 	 			 	 function strtotime(str){
									    var _arr = str.split(' ');
									    var _day = _arr[0].split('-');
									    _arr[1] = (_arr[1] == null) ? '0:0:0' :_arr[1];
									    var _time = _arr[1].split(':');
									    for (var i = _day.length - 1; i >= 0; i--) {
									    	if(_day[i][0] == '0')
									    		_day[i] = _day[i].substr(1);
									        _day[i] = isNaN(parseInt(_day[i])) ? 0 :parseInt(_day[i]);
									    };
									    for (var i = _time.length - 1; i >= 0; i--) {

									    	if(_time[i][0] == '0')
									    		_time[i] = _time[i].substr(1);
									        _time[i] = isNaN(parseInt(_time[i])) ? 0 :parseInt(_time[i]);
									    };
									    var _temp = new Date(_day[0],_day[1]-1,_day[2],_time[0],_time[1],_time[2]);

									    return _temp.getTime() / 1000;
									}



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

			    									 	'item_price' : parseFloat(tds[2].innerText),
 
			    									 	'item_num' : parseInt(tds[3].innerText),

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

			    								WaiUntil(function(){

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

	    										WaiUntil(function(){
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



			 }


		//}
	});

}


init();
//page.open('http://www.tmall.com',function(){
	visitItem('http://detail.tmall.com/item.htm?id='+Args.item_sn);
//});






