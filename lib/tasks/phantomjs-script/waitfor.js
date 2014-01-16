exports.init = function(page){

	 page.evaluate(function(){

	 	window.dispatch = function(c, b) {
		    try {
		        var a = document.createEvent("Event");
		        a.initEvent(b, true, true);
		        c.dispatchEvent(a)
		    } catch (d) {
		        alert(d)
		    }
		}


		window.WatiUntilClass = function(condition,func)
		{
			var _cont = condition;
			var _func = func;
			var timeout = 500;
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
					console.log('wait for cont');
					setTimeout(_call, 500); // Ã¿50ºÁÃë¼ì²éÒ»ÏÂ
				}

			}

		}

		window.WaiUntil = function(cont,func)
		{
			var w = new WatiUntilClass(cont,func);
			w.call();
		}


	 });

}