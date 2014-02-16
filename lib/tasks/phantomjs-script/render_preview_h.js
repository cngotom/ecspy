//var upload_url = 'http://yuchenglong.tmall.com/'



waitfor = require('./waitfor');
system = require('system')

var args = system.args;

var Args = {};

if (args.length != 3) {
  console.log('useage:phantomjs render_preview.js <url> <outfile>');
  phantom.exit();
} else {
 	Args.url = args[1];
 	Args.outfile = args[2];
}

var g_height = 0;


function init(page)
{

	page.settings.resourceTimeout = 60000;  //max
	page.onResourceTimeout = function(e) {
		 // console.log(e.errorCode);   // it'll probably be 408 
		  console.log(e.errorString); // it'll probably be 'Network timeout on resource'
		 // console.log(e.url);         // the url whose request timed out
		  phantom.exit(1);
	};
	page.onConsoleMessage = function(msg) {

			console.log(msg);
	};


	page.onAlert = function(h)
	{

		if(g_height == 0)
		{
			

			g_height = h;

			console.log(g_height);
			phantom.exit();

		}
		else{

			page.render(Args.outfile);
			phantom.exit();

		}
		
	};
}

var page = require('webpage').create();
init(page);
//first get height
page.open(Args.url, function(status) {
	if ( status === "success" ) {
		 if(page.injectJs("jQuery.min.js"))
		 {
		 	
				waitfor.init(page);
			 	//setTimeout(function(){
			 		page.evaluate(function(){

			 			function getDocHeight() {
						    var D = document;
						    return Math.max(
						        Math.max(D.body.scrollHeight, D.documentElement.scrollHeight),
						        Math.max(D.body.offsetHeight, D.documentElement.offsetHeight),
						        Math.max(D.body.clientHeight, D.documentElement.clientHeight)
						    );
						}
			 	 		WaiUntil(
				 	 		function(){
				 	 			$('img').each(function(ele,index){

				 	 				if($(ele).attr('data-ks-lazyload') )
				 	 					return false;
				 	 			})
				 	 			return true;
				 	 		},function(){
				 	 			alert(getDocHeight());
				 	 		}
				 	 	);

			 		});
			 //	},10000);
		}

	 }
});


