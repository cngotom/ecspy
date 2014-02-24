casper = require("casper").create
	clientScripts: ["jQuery.min.js"],
	verbose: true,
    logLevel: "debug"


casper.on "end" ,(output) ->
	@echo output




id = '37257062478' #down


id = '25712504428'
time = 1392726630




Condition =
	DescLoadEnd : ->
		@echo 'wait for'
		res = casper.evaluate(->
			$('#description>div.content img').each (index,ele) -> 
				if($(ele).attr('data-ks-lazyload'))
					alert $(ele).html().trim()

					return false;
			return $('#J_TabBar li:eq(2) a').html() != undefined && $('#description>div.content').html().trim()!='描述加载中';		
		)
		return res

casper.on 'url.changed',->
	#item not found
	if casper.getCurrentUrl()  == 'http://detail.tmall.com/auction/noitem.htm?type=1'
		@echo 'items not found'
		@echo casper.getCurrentUrl()
		casper.run ->




output = ''


handlePage = ->
	#get data
	output += @evaluate ->
		window.getCurrentPgae()
	#click to next page

	@evaluate
		link = $('.pagination a:last')[0];
		if(!link || link.innerHTML.indexOf('下一页') ==-1)
			window.callPhantom(output);
			alert('close');
		dispatch(link, "click");


	#wait for next page
	@waitForSelectorTextChange '#J_showBuyerList tr:nth-child(2)',->
		getNext.call self,page + 1


getNext => (page)
	if page > 20



	else

		if page == 0

		else
			handle()


		if(page == 0)
    									{


    										//save content
											var content = $('#description').html();

		    								//handle \n
		    								content = content.replace(/\n/g,'');
		    								window.callPhantom(content + "\n"); //first line is content



		    								//tmall .J_TDealCount.tm-MRswitchRecord
    										if(parseInt( $('.J_TDealCount').html()) >0) {

	    										WaiUntil(function(){
	    											var pos = getElementAbsPos($('#J_showBuyerList')[0]);
			 	 									window.scroll(pos.left,pos.top);

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



	


casper.start "http://detail.tmall.com/item.htm?id=#{id}",->
	@scrollTo 0,6495
	@waitFor Condition.DescLoadEnd,->
		@evaluate
				getElementAbsPos = ->(e)
					var t = e.offsetTop;
				    var l = e.offsetLeft;
				    while(e = e.offsetParent)
				        t += e.offsetTop;
						l += e.offsetLeft;
				    return {left:l,top:t};

				strtotime = -> (str)
				    var _arr = str.split(' ');
				    var _day = _arr[0].split('-');
				    _arr[1] = (_arr[1] == null) ? '0:0:0' :_arr[1];
				    var _time = _arr[1].split(':');

				    for (var i = _day.length - 1; i >= 0; i--) 
				    	if(_day[i][0] == '0')
				    		_day[i] = _day[i].substr(1);
				        _day[i] = isNaN(parseInt(_day[i])) ? 0 :parseInt(_day[i]);

				    for (var i = _time.length - 1; i >= 0; i--) 
				    	if(_time[i][0] == '0')
				    		_time[i] = _time[i].substr(1);
				        _time[i] = isNaN(parseInt(_time[i])) ? 0 :parseInt(_time[i]);

				    var _temp = new Date(_day[0],_day[1]-1,_day[2],_time[0],_time[1],_time[2]);
				    return _temp.getTime() / 1000;


				var pos = getElementAbsPos($('#J_showBuyerList')[0]);
			 	window.scroll(pos.left,pos.top);

 	 			var link = $('#J_TabBar li:eq(2) a')[0];

 	 			console.log("J_showBuyerList is " + link.innerHTML);
				dispatch(link, "click");



				window.getCurrentPgae = ->
					output = ''
					$('#J_showBuyerList tr:gt(0)').each ->
						 # literate through array or object 
						line = '';
						tds = $(tr).find('td');
						data  = {};

						if window.location.host == "item.taobao.com"
							data = 
							 	'user_name' : tds[0].innerText.trim(),

							 	'item_price' : parseFloat( $(tr).find('.tb-rmb-num').html() ),

							 	'item_num' : parseInt($(tr).find('.tb-amount').html() ),

							 	'buy_time' : $(tr).find('.tb-time').html()
		    			else
		    				data = 
							 	'user_name' : tds[0].innerText.trim(),

							 	'item_price' : parseFloat(tds[2].innerText),

							 	'item_num' : parseInt(tds[3].innerText),

							 	'buy_time' : tds[4].innerText

						current_timestamp = strtotime(data['buy_time']);

						console.log(data['buy_time']);
						console.log("current: " + current_timestamp );
						console.log("start_time: " + window.start_time );

						if( current_timestamp <  window.start_time)
							window.callPhantom(output);
							alert('close');

						output = output + JSON.stringify(data)  + "\n";
					return output;



				getNext = -> (page)
					if(page >= 20) 
						window.callPhantom(output);
						alert('close');

    								
    				else
    					handle = ->
    						console.log('start page :' + page);
    						$('#J_showBuyerList tr:gt(0)').each ->
    							 # literate through array or object 
								line = '';
								tds = $(tr).find('td');
								data  = {};


								if window.location.host == "item.taobao.com"
									data = 
									 	'user_name' : tds[0].innerText.trim(),

									 	'item_price' : parseFloat( $(tr).find('.tb-rmb-num').html() ),

									 	'item_num' : parseInt($(tr).find('.tb-amount').html() ),

									 	'buy_time' : $(tr).find('.tb-time').html()
				    			else
				    				data = 
									 	'user_name' : tds[0].innerText.trim(),

									 	'item_price' : parseFloat(tds[2].innerText),

									 	'item_num' : parseInt(tds[3].innerText),

									 	'buy_time' : tds[4].innerText

								current_timestamp = strtotime(data['buy_time']);

								console.log(data['buy_time']);
								console.log("current: " + current_timestamp );
								console.log("start_time: " + window.start_time );
								if( current_timestamp <  window.start_time)
									window.callPhantom(output);
									alert('close');


								output = output + JSON.stringify(data)  + "\n";

					

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
		    								window.callPhantom(content + "\n"); //first line is content



		    								//tmall .J_TDealCount.tm-MRswitchRecord
    										if(parseInt( $('.J_TDealCount').html()) >0) {

	    										WaiUntil(function(){
	    											var pos = getElementAbsPos($('#J_showBuyerList')[0]);
			 	 									window.scroll(pos.left,pos.top);

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




	,-> 
		@echo 'wait timeout'
		@exit(3)
	,8000



casper.run ->
	;