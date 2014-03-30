waitfor = require('./waitfor');
upload = require('./upload')

system = require('system')
fs = require('fs')

var args = system.args;

var Args = {};

if (args.length != 4) {


  console.log('useage:phantomjs getztc.js  <keyword> <outfile> <logfile>');
  phantom.exit();

} else {
 
 	Args.keyword = args[1];
 	Args.outfile = args[2];
 	Args.logfile = args[3];

}


log = function(msg)
{
	//fs.write(Args.logfile , msg + "\n", 'a');
	//console.log(msg);
}

var output = [];
var current = 0;

function init()
{
	page = require('webpage').create();
	page.settings.resourceTimeout = 20000; // 5 seconds
	page.cookiesEnabled = true;
	page.onResourceTimeout = function(e) {
	 // console.log(e.errorCode);   // it'll probably be 408 
	  console.log(e.errorString); // it'll probably be 'Network timeout on resource'
	 // console.log(e.url);         // the url whose request timed out
	  phantom.exit(1);
	};

	// page.onResourceReceived = function(response) {
	// 	if(response.contentType == "application/x-javascript")
	//   console.log('Response (#' + response.id + ', stage "' + response.stage + '"): ' + JSON.stringify(response));
	// };

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

			 fs.write(Args.outfile, JSON.stringify(output), 'a');

			 console.log('ok'); //return code

			 phantom.exit();
			 // upload.ecspy_upload('ecspy-list_data',5,Args.outfile)

			 // window.setTimeout(function () {
	   //          phantom.exit();
	   //       }, 3000);
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
	page.onError = function(msg, stack) {
	  log("FATAL ERROR!\nMessage: " + msg + "\nStack: " + JSON.stringify(stack));
	}


	



}

init();
function waitFor(testFx, onReady, timeOutMillis) {
    var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 80000, //< Default Max Timout is 3s
        start = new Date().getTime(),
        condition = false,
        interval = setInterval(function() {
            if ( (new Date().getTime() - start < maxtimeOutMillis) && !condition ) {
                // If not time-out yet and condition not yet fulfilled
                condition = (typeof(testFx) === "string" ? eval(testFx) : testFx()); //< defensive code
            } else {
                if(!condition) {
                    // If condition still not fulfilled (timeout but condition is 'false')
                    log("'waitFor()' timeout");
                    phantom.exit(1);
                } else {
                    // Condition fulfilled (timeout and/or condition is 'true')
                    log("'waitFor()' finished in " + (new Date().getTime() - start) + "ms.");
                    typeof(onReady) === "string" ? eval(onReady) : onReady(); //< Do what it's supposed to do once the condition is fulfilled
                    clearInterval(interval); //< Stop this interval
                }
            }
        }, 250); //< repeat check every 250ms
};




function handle(url)
{

	init();
	page.open(url,function(status){
		log(url);
		if ( status === "success" ) {
			if(page.injectJs("jQuery.min.js")  )
			 {
			 	


			 	waitFor(function(){

			 		return page.evaluate(function(){
			 			//console.log($('.ad-p4p-fashion').html());
			 			return $('#J_shopkeeper').length > 0;
			 		});

			 	},function(){
				 	res = page.evaluate(function(){

				 			var res =[];
				 			$('#J_shopkeeper .item').each(
								function(index,ele){

									var data ={
										'id':$(ele).attr('id'),
										'title':$(ele).find('.pic a').attr('title'),
										'img' : $(ele).find('.pic a img').attr('src'),
										'link':$(ele).find('.pic a').attr('href')
									};


									res.push(data); 
								}
							)
							return res;
				 	});

				 	output = output.concat(res);


				 

				 	var next = page.evaluate(function(){
				 		if($('.page-next')[0] == undefined)
				 		{
				 			alert('close');
				 		}
				 		else{
				 			return "http://s.taobao.com" + $('.page-next').attr('href');
				 		}

				 	});

				 	current+=1;

			 		if(current >= 1)
			 		 page.evaluate(function(){
			 		 	alert('close');
			 		 });

				 	handle(next);
				});
			 }
		}
	})



}


handle('http://s.taobao.com/search?q=' + Args.keyword);

// page.open("http://www.taobao.com",function(status){
// 		if ( status === "success" ) {

// 			 if(page.injectJs("jQuery.min.js"))
// 			 {
			 	 
// 			 	 page.evaluate( "function(){  window.keyword = '" +  Args.keyword +"' ; }");


// 			 	 page.evaluate(function() {
// 			 	 	$('#q').val(window.keyword);


// 					console.log(window.keyword);

// 					var link = $('.btn-search')[0];

// 					link.click();
// 			 	 	//dispatch(link,"click");

// 			  	 });

		
// 			 	 //wait for search result loaded
// 			 	waitFor(function() {
// 		            // Check in the page if a specific element is now visible
// 		        	console.log(page.url);

// 		        	if(page.url != 'http://www.taobao.com/')
// 		        	{
// 		        		return true;
// 		        	}

// 		        	return false;

// 		        }, function() {

// 		        	page.close();
// 		        	handle(page.url);

// 		        });  



// 			 }
// 		}


// });




