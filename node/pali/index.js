var http = require('http')
var
UTIL = require('util')
URL = require('url-parse')
FS = require('fs')
RESTIFY = require('restify')
SOCKETIO = require('socket.io')
CHECKURL = require('valid-url')
UTF8 = require('utf8')
_consoleLog = console.log
var log = (obj, msg) => {
    msg = msg || ""
    console.log(msg + UTIL.inspect(obj))
}

// var request = require('request');
// FileCookieStore = require('tough-cookie-filestore');
// j = request.jar(new FileCookieStore('cookies.json'));
// request = request.defaults({ jar : j })
// testIndex = 1
// testLoop = 1000

var url = 'http://osb11g.mediaset.it:8021/PalinsestiOSB/PS/PS_MHPService?getMHPData';
var args = {name: 'value'};
soap.createClient(url, function(err, client) {
    client.MyFunction(args, function(err, result) {
        console.log(result);
    });
});

var myService = {
    MyService: {
        MyPort: {
            MyFunction: function(args) {
                return {name: args.name};
            },
            MyAsyncFunction: function(args, callback) {
                callback({name: args.name});
            },
            // This is how to receive incoming headers
            HeadersAwareFunction: function(args, cb, headers) {
                return {name: headers.Token};
            },
            // You can also inspect the original `req`
            reallyDetailedFunction: function(args, cb, headers, req) {
                console.log('SOAP `reallyDetailedFunction` request from ' + req.connection.remoteAddress);
                return {name: headers.Token};
            }
        }
    }
};

var xml = require('fs').readFileSync('paliReq.wsdl', 'utf8'),
    server = http.createServer(function(request,response) {
        response.end("404: Not Found: "+request.url)
    });

server.listen(8021);
soap.listen(server, '/wsdl', myService, xml);
server.log = function(type, data) {
    // type is 'received' or 'replied' 
};

// server.authenticate = function(security) {
//     var created, nonce, password, user, token;
//     token = security.UsernameToken, user = token.Username,
//     password = token.Password, nonce = token.Nonce, created = token.Created;
//     return user === 'user' && password === soap.passwordDigest(nonce, created, 'password');
// };


var soapPali = () => {
    try {
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open('POST', 'http://osb11g.mediaset.it:8021/PalinsestiOSB/PS/PS_MHPService?getMHPData', true);
	var params = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mhp="http://rti.mediaset.it/onair/main/MHPService">' + 
	    '<soapenv:Header/>' + 
	    '<soapenv:Body>' + 
	    '<mhp:MhpInput>' + 
	    '<mhp:channel>C5</mhp:channel>' + 
	    '<mhp:startdttime>22/10/2016 06:00:00</mhp:startdttime>' + 
	    '<mhp:enddttime>22/10/2016 12:00:00</mhp:enddttime>' +
	    '<mhp:duration>5</mhp:duration>' + 
	    '</mhp:MhpInput>' + 
	    '</soapenv:Body>' + 
	    '</soapenv:Envelope>';
	
	xmlhttp.setRequestHeader("Content-type", "text/xml");
	xmlhttp.setRequestHeader("Content-length", params.length);
	xmlhttp.setRequestHeader("Connection", "close");
	
	xmlhttp.onreadystatechange = function() {
	    if(xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		document.getElementById("resultArea").value = xmlhttp.responseText;
	    }
	}
	xmlhttp.send(params);
    } catch(e) {alert(e);}
}


var xml = require('fs').readFileSync('paliReq.wsdl', 'utf8');

//http server example
var server = http.createServer(function(request,response) {
    response.end("404: Not Found: " + request.url);
});

server.listen(8000);
soap.listen(server, '/wsdl', myService, xml);

var app = express();
app.use(bodyParser.raw({type: function(){return true;}, limit: '5mb'}));
app.listen(8021, function(){
    //Note: /wsdl route will be handled by soap module
    //and all other routes & middleware will continue to work
    soap.listen(app, '/wsdl', service, xml);
});
