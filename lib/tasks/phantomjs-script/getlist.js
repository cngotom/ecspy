waitfor = require('./waitfor');


var g_url ;
var g_page = 0;
var page;

function init()
{
	page = require('webpage').create();
	page.onConsoleMessage = function(msg) {
	    console.log(msg);
	};
	page.onCallback = function(msg)
	{

		console.log(msg);
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
			 phantom.exit();
		}

		else if(msg === 'next')
		{
			init();
			g_page+=1;
			visitPage(g_url,g_page);
		}
	};

	page.safeInjectJs = function()
	{



	};
	page.onerror = function() {
	    console.log("this is never invoked");
	};

}

init();


function visitPage(url,pageNo)
{
	var currentUrl = url + '/search.htm?pageNo=' + pageNo;
	page.open(currentUrl, function(status) {
		console.log('pageStart');
		if ( status === "success" ) {

			 if(page.injectJs("jQuery.min.js"))
			 {
			 	 console.log('loadJs end');

			 	 page.evaluate(function() {

			 	 		if($('dl.item').size() >0 ){
			 	 		
			 	 			$('dl.item').each(function(index,ele){

			 	 				var price = $(ele).find('.c-price').text().trim();
			 	 				var title = $(ele).find('.item-name').text().trim();
			 	 				var num = $(ele).find('.sale-num').html();
			 	 				var cnum = $(ele).find('.title a').html();

			 	 				window.callPhantom($(ele).attr('data-id'));
			 	 				//console.log($(ele).html());
			 	 				window.callPhantom("title: " + title);
			 	 				window.callPhantom("num: " + num);
			 	 				window.callPhantom("cnum: " + cnum);
			 	 				window.callPhantom("price: " + price);



			 	 			});

			 	 			alert('next');

			 	 		}
			 	 		else{
			 	 			alert('close');
			 	 		}
				 

			 	 });



			 }
			 else{

			 	console.log('load error');
			 	alert('close');
			 }


		}
	});

}



function visitList(url)
{
	g_url = url;
	g_page = 1;

	visitPage(g_url,g_page);
}

visitList('http://slwsp.tmall.com');









