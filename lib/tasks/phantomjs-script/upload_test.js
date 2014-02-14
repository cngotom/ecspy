upload = require('./upload')

upload.ecspy_upload('aaa',5,'./waitfor.js')


 window.setTimeout(function () {
	            phantom.exit();
	         }, 3000);