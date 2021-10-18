//https://medium.com/dev-bits/writing-neat-asynchronous-node-js-code-with-promises-32ed3a4fd098
const csv = require('csv-parser');
const fs = require('fs');
var path = require('path');
const https = require('https');
const request = require('request-promise');
const express = require('express')
const app = express()
require('dotenv').config({path: __dirname + '/.env'})

var urlN = "https://nominatim.openstreetmap.org/search?format=json&q="
var urlC = "https://api.opencagedata.com/geocode/v1/json?key="+process.env.OCD_API_KEY+"&pretty=1&q="
const address = 'Via Garibaldi, Salò, Italy';
let stroke_event = [];
var adrL = ['Via Garibaldi, Salò, Italy','Spedali civili, Brescia, Italy'];
var entry = "1";
var adr = adrL[0];
var callL = [];
var row = {'address_unit':adrL[0]'address_call':adrL[1]};

function create_url(addr){return encodeURI(urlC+addr);}
function get_geometry(body){
    var resp = JSON.parse(body);
    return resp['results'][0]['geometry'];
}
var errHandler = function(err) {console.log(err);}
	
function geocode(addr) {
    var options = {url:create_url(addr), headers: {'User-Agent': 'request'}};
    return new Promise(function(resolve, reject) {
        request.get(options, function(err, resp, body) {
            if (err) {
                reject(err);
            } else {
		var coord = get_geometry(body);
		resolve(coord);
            }
        })
    })
}

async function parse_row(row) {
    var initPromise = geocode(row['address_call']);
    initPromise.then(function(coord_call)
		     {
			 var initPromise2 = geocode(row['address_unit']);
			 initPromise2.then(
			     function(coord_unit){
				 var coord = {'lat_unit':coord_unit['lat'],'lng_unit':coord_unit['lng']
					      ,'lat_call':coord_call['lat'],'lng_unit':coord_call['lng']};
				 console.log(coord);
				 callL.push(coord);
			     }, errHandler
			 )
			 return initPromise2;
		     }
		     , errHandler
		    ).then(function(data){
			//console.log(data)
		    }, errHandler
			  );
}

parse_row(row);

var r = null;
fs.createReadStream('calls.csv').pipe(csv()).on('data', (row) => {
    //const coord = await parse_row(row);
    //console.log(coord);
    r = row;
    console.log(row);
    }).on('end', () => {
	console.log('CSV file successfully processed');
    });

// app.get('/', async (request, response) => {
//   const result = await getContent()
//   response.send(result)
// })
// app.listen(process.env.PORT)

var dirCont = fs.readdirSync( "." );
var files = dirCont.filter( function( elm ) {return elm.match(/.*\.(csv?xlsx)/ig);});




