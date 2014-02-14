exports.ecspy_upload = function(type,id,filename){


	var upload_url = 'http://127.0.0.1:3000/file_upload/index'
	var page = require('webpage').create();
	var fs = require('fs')


	page.open(upload_url, function(status) {
		if ( status === "success" ) {

			 page.uploadFile('input[name=data]', filename);

			// console.log(type);

			 page.evaluate( "function(){  window.type = '" + type +   "';window.id = " + id + " ; }");

		 	 page.evaluate(function() {
		 	 	document.querySelector('input[name=type]').value = window.type;
	            document.querySelector('input[name=id]').value = window.id;
	            document.querySelector('form').submit();

		 	 });

		 	

		 }
	});

}