waitfor = require('./waitfor');
upload = require('./upload')

system = require('system')
fs = require('fs')

var args = system.args;

var Args = {};

if (args.length != 2) {


  console.log('useage:phantomjs geturl.js <url>');
  phantom.exit();

} else {
 
 	Args.url = args[1];


}


log = function(msg)
{
	//fs.write(Args.logfile , msg + "\n", 'a');
	//console.log(msg)
}


var g_url ;
var g_page = 0;
var page;

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
		

	
	};

	page.safeInjectJs = function()
	{



	};
	page.onError = function(msg, trace) {
	  	log("Error:" + msg);
	};

}

init();

page.open(Args.url,function(status){
	res = page.evaluate(function() {
			return document.body.innerHTML;
		});
	console.log(res);
	phantom.exit();
});	



