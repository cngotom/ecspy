upload = require('./upload')
pageext = require("./lib/pageext.js")

system = require('system')

var args = system.args;

var Args = {};

if (args.length != 5) {


  console.log('useage:phantomjs getlist.js <url> <shop_id> <outfile> <logfile>');
  phantom.exit();

} else {
 
 	Args.url = args[1];
 	Args.shopid = args[2];
 	Args.outfile = args[3];

 	Args.logfile = args[4];


}


var g_url ;
var g_page = 0;
var page;

function init()
{
	page = require('webpage').create();
	page = pageext.create({LogFile:Args.logfile,ResFile:Args.outfile});

  page.oldOnAlert = page.onAlert
	page.onAlert = function(msg)
	{
		 // upload.ecspy_upload('ecspy-list_data',5,Args.outfile)
		if(msg === 'next')
		{
			page.close();
			init();
			g_page+=1;
			visitPage(g_url,g_page);
		}
    else
    {
      page.oldOnAlert(msg)
    }
	};

}

init();


function visitPage(url,pageNo)
{
	var currentUrl = url + '/search.htm?pageNo=' + pageNo;
	page.open(currentUrl, function(status) {
		page.Log('pageStart');
	//	if ( status === "success" ) {

			 if(page.injectJs("jQuery.min.js"))
			 {
			 	 page.Log('loadJs end');


			 	 page.evaluate( "function(){  window.shopid = " +  Args.shopid +"  }");

			 	 page.evaluate(function() {

			 	 		if($('dl.item').size() >0 && $('.no-result-new').length == 0 ){
			 	 			
			 	 			var out = "";
			 	 			$('dl.item').each(function(index,ele){

			 	 				var price = $(ele).find('.c-price').text().trim();
			 	 				var title = $(ele).find('.item-name').text().trim();
			 	 				var num = $(ele).find('.sale-num').html();
			 	 				var cnum = $(ele).find('.title a span').html();

			 	 				var thumb = $(ele).find('.photo img').attr('data-ks-lazyload');
			 	 				if(thumb == undefined)
			 	 					thumb = $(ele).find('.photo img').attr('src');
			 	 				if(cnum)
                {
			 	 					cnum = cnum.replace("评价: ","")
			 	 				  console.log(cnum);
                }

			 	 				var data = {
			 	 					'item_sn' :  $(ele).attr('data-id'),
			 	 					'price' : parseFloat(price),
			 	 					'title' : title,
			 	 					'sales_count' : parseInt(num),
			 	 					'comments_count' :parseInt(cnum),
			 	 					'thumb' : thumb,
			 	 					'shop_id' :window.shopid,
			 	 				}
			 	 				//console.log('thumb:' + thumb);

			 	 				//out = '123'
			 	 				out = out + JSON.stringify(data)  + "\n";
			 	 				// window.callPhantom($(ele).attr('data-id'));
			 	 				// //console.log($(ele).html());
			 	 				// window.callPhantom("title: " + title);
			 	 				// window.callPhantom("num: " + num);
			 	 				// window.callPhantom("cnum: " + cnum);
			 	 				// window.callPhantom("price: " + price);



			 	 			});

			 	 			window.callPhantom(out);

			 	 			alert('next');

			 	 		}
			 	 		else{
			 	 			alert('close');
			 	 		}
				 

			 	 });



			 }
			 else{

			 	page.Log('load error');
			 	alert('close');
			 }


		//}
	});

}



function visitList(url)
{
	g_url = url;
	g_page = 1;

	visitPage(g_url,g_page);
}

visitList(Args.url);









