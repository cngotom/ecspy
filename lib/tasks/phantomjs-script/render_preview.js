//var upload_url = 'http://yuchenglong.tmall.com/'



waitfor = require('./waitfor');
system = require('system')

var args = system.args;

var Args = {};

if (args.length != 4) {
  console.log('useage:phantomjs render_preview.js <url> <outfile> <height> ');
  phantom.exit();
} else {
 	Args.url = args[1];
 	Args.outfile = args[2];
 	Args.height = args[3];
}



function init(page)
{
	page.settings.resourceTimeout = 60000;  //max
	page.viewportSize = {
			  width: 1280,
			  height: Args.height
	};	
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
		
		page.render(Args.outfile);
		console.log('ok')
		phantom.exit();
		
	};
}

var page = require('webpage').create();
init(page);
//first get height
page.open(Args.url, function(status) {
	if ( status === "success" ) {
 		page.evaluate(function(){
			 setTimeout(function(){
	 	 		alert(1);
	 	 	},10000);
 		});
	 }
});
