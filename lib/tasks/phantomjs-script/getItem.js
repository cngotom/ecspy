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
	fs.write(Args.logfile , msg + "\n", 'a');

}



function init()
{
	page = require('webpage').create();
	page.settings.resourceTimeout = 20000; // 5 seconds
	page.onResourceTimeout = function(e) {
	 // console.log(e.errorCode);   // it'll probably be 408 
	  console.log(e.errorString); // it'll probably be 'Network timeout on resource'
	 // console.log(e.url);         // the url whose request timed out
	  phantom.exit(1);
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
	page.onerror = function() {
	    console.log("this is never invoked");
	};

	log('start item :' + Args.item_sn);


}









function visitItem(url)
{

	page.open(url, function(status) {
		log('pageStart');
		if ( status === "success" ) {

			 if(page.injectJs("jQuery.min.js"))
			 {
			 	 log('loadJs end');

			 	 page.scrollPosition = {
			  		top: 6495,
			  		left: 0
				 };

				 waitfor.init(page);

			 	 page.evaluate( "function(){  window.start_time = " +  Args.start_time +"  }");


			 	 page.evaluate(function() {


			 	 		WaiUntil(
				 	 		function(){
				 	 			return $('#J_TabBar li:eq(2) a').html() != undefined;		
				 	 		},
				 	 		function(){

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


				 	 			var link = $('#J_TabBar li:eq(2) a')[0];
    							dispatch(link, "click");

    							var output = '';

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


			    									 var data = {

			    									 	'user_name' : tds[0].innerText.trim(),

			    									 	'item_price' : parseFloat(tds[2].innerText),
 
			    									 	'item_num' : parseInt(tds[3].innerText),

			    									 	'buy_time' : tds[4].innerText,
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

    										if(parseInt( $('.J_TDealCount.tm-MRswitchRecord').html()) >0) {

	    										WaiUntil(function(){return $('#J_showBuyerList tr').length > 0}
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


		}
	});

}


init();
visitItem('http://detail.tmall.com/item.htm?id='+Args.item_sn);









