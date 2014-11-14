fs = require('fs')
waitfor = require("./waitfor.js")
utils = require("./utils.js")



function AddMessageHandler(page,options)
{
  Log = function(msg)
  {
    if(options.LogFile != "")
      fs.write(options.LogFile , msg +  "\n", 'a');
  }

  Print = function(msg)
  {
    console.log(msg)
  }

  page.Log = Log
  page.Print = Print
	page.settings.resourceTimeout = options.ScriptMaxMillTime; // 20 seconds
	//page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.57 Safari/537.36';
	page.onResourceTimeout = function(e) {
	  Log(e.errorString); // it'll probably be 'Network timeout on resource'
	  Log(e.url);         // the url whose request timed out
	};
	page.onConsoleMessage = function(msg) {
		Log(msg);
	};
	page.onCallback = function(msg)
	{
    if(options.ResFile != "")
     fs.write(options.ResFile , msg +  "\n", 'a');
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
       //incase of  Unsafe JavaScript attempt to access frame with URL
      // setTimeout(function(){
           phantom.exit();
      // }, 0);

		}
		else if( msg === 'timeout' )
		{
			 console.log('timeout'); //return code
			 phantom.exit();
		}
		else if( msg === 'render' )
		{
      page.render("screen.png")
    } 

		

	};

	page.onError = function(msg, trace) {
	  	Log("Error:" + msg + trace);
	};
  
  page.viewportSize = {
    width: 800,
    height: 1280
  };

}


exports.create = function(options){
  //options
  options = options || {}
  var default_options = {
    LogFile :  "",
    ResFile :  "",
    JqueryEnabled : true,
    ScriptMaxMillTime : 20000
  }
  options = utils.merge_options(default_options,options)


	page = require('webpage').create();
  AddMessageHandler(page,options)

  //add waitfor
  return page;
}



exports.addUtils = function(page,options) {
  options = options || {}
  if(options.Jauery != false)
  {
		 page.injectJs("./jQuery.min.js")
  }

  if(options.Waitfor != false)
  {
    waitfor.init(page)
  }

  if(options.Utils != false)
  {
			 	page.evaluate(function(){
			 			window.getDocHeight = function() {
						    var D = document;
						    return Math.max(
						        Math.max(D.body.scrollHeight, D.documentElement.scrollHeight),
						        Math.max(D.body.offsetHeight, D.documentElement.offsetHeight),
						        Math.max(D.body.clientHeight, D.documentElement.clientHeight)
						    );
						};




            window.getElementAbsPos= function(e) 
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

            window.strtotime = function(str){
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
    });
  }
            

}
