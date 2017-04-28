
// http://tags.bluekai.com/site/30931?ret=js
// http://prontointavola.tgcom24.it/
// http://www.tgcom24.mediaset.it/sport/

var request = require('request');
FileCookieStore = require('tough-cookie-filestore');
j = request.jar(new FileCookieStore('cookies.json'));
request = request.defaults({ jar : j })
testIndex = 1
testLoop = 1000

requestJSONReturn = (loopIndex) =>{
    if(loopIndex >= testLoop)
	return

    request('http://tags.bluekai.com/site/28585?ret=js', function (error, response, body) {
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

requestJSONReturn(0);
