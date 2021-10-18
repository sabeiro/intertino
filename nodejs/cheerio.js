var parser = require("htmlparser2");
var request = require('request');
var sys = require('util');
var fs = require('fs');
var cheerio = require('cheerio');
var cred = JSON.parse(fs.readFileSync(process.env.LAV_DIR + 'credenza/geomadi.json', 'utf8'));
var cookL = JSON.parse(fs.readFileSync('google-cookies.json', 'utf8'))['cookies'];
var urlL = JSON.parse(fs.readFileSync('url_list.json', 'utf8'));
var headL = JSON.parse(fs.readFileSync('header_list.json', 'utf8'));
var request = require('request');
//rss
//amflaff
var baseUrl = urlL['url'][0]
var headerD = headL['header1']
var cook = cookL[Object.keys(cookL).find(key => cookL[key]['name'] === '1P_JAR')]
cook['expirationDate'] = new Date().getTime() + 86409000;
// headerD['Cookie'] = cook
function log(txt){console.log(txt);}
function dumpPage(body){
    fs.writeFile("/tmp/test.html",body, function(err) {
	if(err) {
            return console.log(err);
	}
	console.log("The file was saved!");
    }); 
}    
function readIt(body){
    var $ = cheerio.load(body);
    var occTime = []
    $('.section-popular-times-graph').each(function(i,curveL) {
	log(curveL);
	$('.section-popular-times-value',curveL).each(function(j,labL) {
	    occTime.push(labL.parentNode.attributes['aria-label'].nodeValue);
	});
    });
    log(occTime);
    return $;
}
var $ = "";
request({url:baseUrl,method: 'GET',headers:headerD},function(error,response,body){if (!error && response.statusCode == 200) {$ = cheerio.load(body);}});
$('.section-popular-times-graph').text()




var $ = cheerio.load(bodyT);
var occTime = []
$('.section-popular-times-graph').each(function(i,curveL) {
    log(curveL);
    $('.section-popular-times-value',curveL).each(function(j,labL) {
	occTime.push(labL.parentNode.attributes['aria-label'].nodeValue);
    });
});


testIndex = 1
testLoop = 1000
requestJSONReturn = (loopIndex) =>{
    if(loopIndex >= testLoop)
	return
    var $ = "";
    request({url:baseUrl
	     ,method: 'GET'
	     ,headers:headerD
	     //,body:bodyReq
	     //,form:formD
	    }
	    , function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    $ = readIt(body);
		}
	    });
}
requestJSONReturn(0);

