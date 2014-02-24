var casper = require("casper").create({
	clientScripts: ["jQuery.min.js"]
});
casper.on("end", function(output) {
   	this.echo(output);

});



var id = '35018792719'

var time = 1392726630


casper.start('http://detail.tmall.com/item.htm?id=' + id , function(){

	casper.on('url.changed',function(){
		//item not f
		this.echo 'items not found'
		this.exit(2);
	})

})



casper.run(function(){

	
});