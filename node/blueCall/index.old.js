// http://tags.bluekai.com/site/30931?ret=js

var
urlContainer = 'http://services.bluekai.com/Services/WS/sites'
urlCategories = 'http://services.bluekai.com/Services/WS/sites'
urlRules = 'http://services.bluekai.com/Services/WS/classificationRules'
urlTaxonomy = 'http://services.bluekai.com/Services/WS/Taxonomy'
urlAudience = 'http://services.bluekai.com/Services/WS/audiences'
urlClassification = 'http://services.bluekai.com/Services/WS/classificationCategories'
urlOrder = 'http://services.bluekai.com/Services/WS/Order'
urlVertical = 'http://services.bluekai.com/Services/WS/Vertical'

//http://tags.bluekai.com/site/32157

// 515450
// {"AND":[{"AND":[{"OR":[{"cat":515450}]}]}]}



// DEPENDENCIES
var
UTIL = require('util')
URL = require('url-parse')
CRYPTO = require('crypto')
FS = require('fs')
REQUEST = require('request')
CHEERIO = require('cheerio')
SEQUENCE = require('sequence').Sequence
RESTIFY = require('restify')
SOCKETIO = require('socket.io')
CHECKURL = require('valid-url')
UTF8 = require('utf8')
_consoleLog = console.log

var request = require('request');
FileCookieStore = require('tough-cookie-filestore');
j = request.jar(new FileCookieStore('cookies.json'));
request = request.defaults({ jar : j })
testIndex = 1
testLoop = 1000

// GLOBAL PREFERENCES
require('./config/app_config.js')

// LOCAL VARIABLES
var
$ = null
elements = {}
numElements = 0
opml_categories = []
bk_sc_categories = {}
opml_rules = []
bk_sc_rules = {}
bk_sc_limbo_rules_id = []
bk_sc_url_limbo_rules_id = []
bk_sc_phint_limbo_rules_id = []
ascii = /^[ -~]+$/
    OPML_Errors = 0
RULE_Errors = 0
_connetedUsers = 0

resetVariables = () =>{
    elements = {}
    numElements = 0
    opml_categories = []
    bk_sc_categories = {}
    opml_rules = []
    bk_sc_rules = {}
    bk_sc_limbo_rules_id = []
    bk_sc_url_limbo_rules_id = []
    bk_sc_phint_limbo_rules_id = []
    OPML_Errors = 0
}


statusUpdate = (status, origin, description, msg) => {
	//io.emit('api update', { "status": status, "origin":origin, "description":description, details: msg })
	io.emit(origin, { "status": status, "origin":origin, "description":description, details: msg })
}
packUpdate = (status, origin, description, msg) => {
	return { "status": status, "origin":origin, "description":description, details: msg }
}
var setMode = (the_mode) => {
	if(_seats[the_mode]){
		_mode = the_mode
		statusUpdate("OK","APP","Set Mode",the_mode)
		loadOPML()
	} else {
		statusUpdate("KO","APP","Set Mode",'mode not valid')
	}
}
var getMode = () => {
	return _mode
}

var signatureInputBuilder = (url, method, data) => {
    var stringToSign = method
    var parsedUrl = new URL(url)
    stringToSign += parsedUrl.pathname
    var qP = parsedUrl.query.split('&')
    if(qP.length > 0){
     	for(qs = 0; qs < qP.length; qs++){
     		var qS = qP[qs]
     		var qP2 = qS.split('=')
            if (qP2.length > 1)
                stringToSign += qP2[1]
     	}
     }
     if(data != null && data.length > 0)
     	stringToSign += data
     var s = CRYPTO.createHmac('sha256', _seats[_mode].secretkey).update(stringToSign).digest('base64')
     //var s = CRYPTO.createHmac('sha256', bksecretkey).update(new Buffer(stringToSign, 'utf-8')).digest('base64')
     u = encodeURIComponent(s)
    var newUrl = url
    if(url.indexOf('?') == -1 )
        newUrl += '?'
    else
        newUrl += '&'
    newUrl += 'bkuid=' + _seats[_mode].uid + '&bksig=' + u
    return newUrl
}

var doRequest = (url, method, data, next) => {
	//if(data)
	//	data = UTF8.encode(data) //(new Buffer(data)).toString('utf-8')
	var newUrl = signatureInputBuilder(url,method,data)
	var options = {
  		url: newUrl,
  		headers: headers,
  		method: method,
  		body: data
  	}
	if(method === "POST"){
		REQUEST.post(options, function(error, data, response, body) {
		  if (error == null ) { // && !error && response.statusCode == 200
		    next(response)
			return (response)
		  } else{next()}//
		})
	}
	if(method === "GET"){
		REQUEST.get(options, function(error, response, body) {
		  if (error == null  && !error && response.statusCode == 200) {
		    next(body)
			return (body)
		  } else{next()}
		})
	}
	if(method === "PUT"){
		REQUEST.put(options, function(error, data, response, body) {
		  if (error == null  && !error && response.statusCode == 200) {
		    next(body)
			return (body)
		  } else{next(response)}
		})
	}
}

var checkSegmentsReach = (nodeIndex, next) => {
	if(nodeIndex == numElements){
		statusUpdate("OK","taxonomy","taxonomy:update:reach:ended",_mode)
		next()
	}
	else{
		elem = $(elements[nodeIndex])
		var BK_category_name = elem.attr('text')

		// IDS
		var the_ids = []
		if(elem.attr('IDS'))
			the_ids = elem.attr('IDS').split(":")
		var BK_category_ID = the_ids[0] || ""

		// BUILD BK QUERY
		var reach_query = "{'AND': [{'OR': [{'cat': "+ BK_category_ID + "}]}]}"

		SEQUENCE.create()
			.then((check_segment_reach_next) => {
				doRequest("http://services.bluekai.com/Services/WS/SegmentInventory?intlDataCountryID=-1", "POST", reach_query,check_segment_reach_next)
			})
			.then((check_segment_reach_next, res) => {
				var reach = 0

				res = JSON.parse(res)
				if(res !== undefined && res != '')
					reach = res["AND"][0].reach

				statusUpdate("OK","taxonomy","taxonomy:update:reach",{"current":(nodeIndex+1),"total": numElements, "reach":{"id": BK_category_ID, "name": BK_category_name, "reach": reach}})
				elem.attr("REACH", reach)
				checkSegmentsReach(++nodeIndex, next)
			})

	}
}

var log = (obj, msg) => {
	msg = msg || ""
	console.log(msg + UTIL.inspect(obj, false, null))
}



requestJSONReturn = (loopIndex) =>{
    if(loopIndex >= testLoop)
	return

    request('http://tags.bluekai.com/site/30931?ret=js', function (error, response, body) {
	if (!error && response.statusCode == 200) {
	    //console.log(body) // Show the HTML for the Google homepage.
	    body = body.replace('var bk_results = ','')
	    body = body.substring(0, body.length-2)
	    //console.log(body)

	    body = JSON.parse(body)
	    campaigns = ''
	    for(i in body.campaigns){
	    	campaigns += body.campaigns[i].campaign + ' '
	    }
	    console.log("TEST #" + loopIndex + " :: " + campaigns)
	    requestJSONReturn(++loopIndex)
	}
    })
}

data = {};
next = {};


//body = doRequest(urlAudience,"GET",JSON.stringify(data),next);
console.log(next)


//requestJSONReturn(0);
