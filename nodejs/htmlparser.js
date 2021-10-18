var http = require('http');
var request = require('request');

var options = {
  host: 'www.google.com',
  port: 80,
  path: '/upload',
  method: 'POST'
};

var options = {
  host: 'www.google.com',
  port: 443,
  path: '/maps/place/Sch%C3%B6nhauser+Allee+Arcaden/@52.5432723,13.4004447,15z/data=!4m5!3m4!1s0x47a85200ffffffff:0xa5239c459b2d413f!8m2!3d52.5496296!4d13.4153607'
};

http.get(options, function(res) {
  console.log("Got response: " + res.statusCode);

  res.on("data", function(chunk) {
    console.log("BODY: " + chunk);
  });
}).on('error', function(e) {
  console.log("Got error: " + e.message);
});


var req = http.request(options, function(res) {
  console.log('STATUS: ' + res.statusCode);
  console.log('HEADERS: ' + JSON.stringify(res.headers));
  res.setEncoding('utf8');
  res.on('data', function (chunk) {
    console.log('BODY: ' + chunk);
  });
});

req.on('error', function(e) {
  console.log('problem with request: ' + e.message);
});

// write data to request body
req.write('data\n');
req.write('data\n');
req.end();


// var htmlparser = require("htmlparser");
// var rawHtml = "Xyz <script language= javascript>var foo = '<<bar>>';< /  script><!--<!-- Waah! -- -->";
// var handler = new htmlparser.DefaultHandler(function (error, dom) {
// 	if (error)
// 		[...do something for errors...]
// 	else
// 		[...parsing done, do something...]
// });
// var parser = new htmlparser.Parser(handler);
// parser.parseComplete(rawHtml);
// sys.puts(sys.inspect(handler.dom, false, null));
