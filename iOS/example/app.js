
var pinger = require('bencoding.pinger');
Ti.API.info("module is => " + pinger);

var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
win.open();

function onCompleted(e){
	Ti.API.info(JSON.stringify(e));	
};

pinger.ping({
	address:'http://www.apple.com',
	completed:onCompleted,
	timeout:15000
});