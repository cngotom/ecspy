utils = require("./utils.js")
exports.init = function(page,options){
  options = options || {}
   var default_options = {
     MaxRetryTime : 10,
     MilliTimeout :500,
     LogOn : false
   }

   default_options = utils.merge_options(default_options,options)

	 page.evaluate(function(options){

	 	window.dispatch = function(c, b) {
		    try {
		        var a = document.createEvent("Event");
		        a.initEvent(b, true, true);
		        c.dispatchEvent(a)
		    } catch (d) {
		        alert(d)
		    }
		}

		window.WaitUntilClass = function(condition,func)
		{
			var maxTime = options.MaxRetryTime;
			var _cont = condition
			var _func = func;
			var timeout =  options.MilliTimeout;
			var ele = this;
			var _call = function()
			{
				
				ele.call();
			} 
			this.call = function()
			{

				if(_cont())
				{
					_func();
				}
				else
				{
					maxTime--;
					if(maxTime <= 0)
					{
						alert('timeout');
					}
          if (options.LogOn)
					  console.log('wait for cont' + condition.toString());
					setTimeout(_call, timeout);
				}

			}

		}

		window.WaitUntil = function(cont,func)
		{
			var w = new WaitUntilClass(cont,func);
			w.call();
		}

	 },default_options);

}
