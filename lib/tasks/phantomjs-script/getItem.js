var page = require('webpage').create();
waitfor = require('./waitfor');

page.onConsoleMessage = function(msg) {
    console.log(msg);
};

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
		 phantom.exit();
	}
}





function visitItem(url)
{

	page.open(url, function(status) {
		console.log('pageStart');
		if ( status === "success" ) {

			 if(page.injectJs("jQuery.min.js"))
			 {
			 	 console.log('loadJs end');

			 	 page.scrollPosition = {
			  		top: 6495,
			  		left: 0
				 };

				 waitfor.init(page);
			 	 page.evaluate(function() {
			 	 		WaiUntil(
				 	 		function(){
				 	 			return $('#J_TabBar li:eq(2) a').html() != undefined;		
				 	 		},
				 	 		function(){



				 	 			//输出产品信息
				 	 			var title = $('.tb-detail-hd h3').text().trim();
				 	 			var desc = $('.tb-detail-hd p').text().trim();

				 	 			//getprice
				 	 			var price = 1000000000; //very big
				 	 			WaiUntil(function(){ return $('.tm-price')},
				 	 			function(){
				 	 				$('.tm-price').each(function(index,ele){
				 	 					var nowprice =  parseFloat($(ele).text());
				 	 					//console.log("nowprice: " + nowprice);	
				 	 					if(price > nowprice)
				 	 						price = nowprice;

				 	 				});
				 	 			});


			 	 				console.log("title: " + title);
			 	 				console.log("desc: " + desc);
			 	 				console.log("price: " + price);


				 	 			//($('#J_TabBar li:eq(2) a')[0]).click();
				 	 			var link = $('#J_TabBar li:eq(2) a')[0];
    							dispatch(link, "click");


    							function getNext(page)
    							{

    								if(page >= 20)
    									alert('close');
    								else {

    									WaiUntil(function(){return $('#J_showBuyerList tr').size()>1}
		    							,function(){

			    								
			    								console.log(page);

			    								$('#J_showBuyerList tr:gt(0)').each(function(indexi,tr) {
			    									 /* iterate through array or object */

			    									var line = '';

			    									 $(tr).find('td').each( function(indexj,td) {

			    									 		line = line + td.innerText+ '  ';
			    									 });

			    									console.log(line);


			    								});

			    								var nowTrValue = $('#J_showBuyerList tr:eq(1)').html();

			    								var link = $('.pagination a:last')[0];
			    								if(!link || link.innerHTML.indexOf('下一页') ==-1)
			    									alert('close');

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


			    						});

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

visitItem('http://detail.tmall.com/item.htm?id=10609596736');









