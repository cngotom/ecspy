
//init with 
var casper = require("casper").create({
	clientScripts: ["jQuery.min.js"]
});


casper.on("end", function(output) {
   	this.echo(output);

});



var GetList = {

	Conditions : {
		//if item exists
		'ItemExists':function(){
			return ($('dl.item').size() >0 && $('.no-result-new').length == 0 )
		}
	},

	//gather output
	outPut : '',
	curPageNo : 1,
	//code execute to get items
	getItemsCode : function(){
		return this.evaluate(function() {
			var out = "";
			$('dl.item').each(function(index,ele){
				var price = $(ele).find('.c-price').text().trim();
				var title = $(ele).find('.item-name').text().trim();
				var num = $(ele).find('.sale-num').html();
				var cnum = $(ele).find('.title a span').html();

				var thumb = $(ele).find('.photo img').attr('data-ks-lazyload');
				if(thumb == undefined)
					thumb = $(ele).find('.photo img').attr('src');
				console.log(cnum);
				if(cnum)
					cnum = cnum.replace("评价: ","")
				console.log(cnum);

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
			})
			return out;
		});

	},

	doGetList : function(){
		if( this.evaluate(GetList.Conditions.ItemExists))
		{
			this.echo(GetList.curPageNo);
			GetList.outPut += GetList.getItemsCode.call(this)
			GetList.curPageNo += 1; 
			this.thenOpen(url + '/search.htm?pageNo='+GetList.curPageNo,GetList.doGetList)
		}
		else{

			this.emit('end',GetList.outPut);
		}
	}



}
// casper getlist.js <url>


url = 'http://slwsp.tmall.com'


casper.start( url + '/search.htm?pageNo='+ GetList.curPageNo, GetList.doGetList);

casper.run();