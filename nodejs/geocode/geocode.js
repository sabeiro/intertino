//https://medium.com/dev-bits/writing-neat-asynchronous-node-js-code-with-promises-32ed3a4fd098
const csv = require('csv-parser');
const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');
const request = require('request-promise');
const bodyParser = require('body-parser');
const multer = require('multer');
const xlstojson = require("xls-to-json-lc");
const xlsxtojson = require("xlsx-to-json-lc");
const express = require('express');
const helmet = require("helmet");

//-----------------------------https-and-credentials---------------------------
const crypto = require('crypto');
var privateKey = fs.readFileSync('conf/privkey.pem').toString();
var certificate = fs.readFileSync('conf/fullchain.pem').toString();
var cred = {key: privateKey, cert: certificate,requestCert:false,rejectUnauthorized:false};
// var credentials = crypto.createCredentials(cred);
require('dotenv').config({path: __dirname + '/.env'})
const app = express()
app.use(bodyParser.json());
app.use(express.static(__dirname + '/public'));
app.use(express.static('public')); //Serves resources from public folder
app.use(helmet()); // Add Helmet as a middleware

//-------------------------set-variables-----------------------------
var urlN = "https://nominatim.openstreetmap.org/search?format=json&q="
var urlC = "https://api.opencagedata.com/geocode/v1/json?key="+process.env.OCD_API_KEY+"&pretty=1&q="
const address = 'Via Garibaldi, Salò, Italy';
let stroke_event = [];
var adrL = ['Via Garibaldi, Salò, Italy','Spedali civili, Brescia, Italy'];
var entry = "1";
var adr = adrL[0];
var callL = [];
var row = {'address_unit':adrL[0],'address_call':adrL[1]};
var row_db = null;
var endpoint = '/intertino/node/geocode/lib/db.php'
var domain = 'http://localhost'
var dirCont = fs.readdirSync( "." );
var files = dirCont.filter( function( elm ) {return elm.match(/.*\.(csv?xlsx)/ig);});

//----------------------geocode-section-----------------------

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

//--------------------------etl-section------------------------------

function trimFloat(num) {
    if (num > 0)
	return Math.floor(num * 1000) / 1000;
    else
	return Math.ceil(num * 1000) / 1000;
}

function key_row(row,coord){
    var row_db = {};
    for (var key in row) {
	if (row.hasOwnProperty(key)) {
            if( key.match('address') === null ){
		row_db[key] = row[key];
	    }
	}
    }
    for (var key in coord) {
	row_db[key] = trimFloat(coord[key]);
    }
    return row_db;
}

//------------------------database-ingestion------------------------

function row2db(row_db){
    request({url:domain + endpoint,
	     method:'POST',
	     json:true,
	     body:row_db
	    }, function (error, response, body) {
		if (!error && response.statusCode == 200) {
		    console.log(body);
		}
	    }
	   );
}

//----------------------concatenate-promises-------------------------

async function parse_row(row) {
    var initPromise = geocode(row['address_call']);
    initPromise.then(function(coord_call)
		     {
			 var initPromise2 = geocode(row['address_stroke_unit']);
			 initPromise2.then(
			     function(coord_unit){
				 var coord = {'lat_unit':coord_unit['lat'],'lng_unit':coord_unit['lng']
					      ,'lat_call':coord_call['lat'],'lng_call':coord_call['lng']};
				 row_db = key_row(row,coord);
				 row2db(row_db);
				 console.log(row);
				 console.log(row_db);
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

//------------------------------file-handling--------------------------------

var storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './uploads/')
    },
    filename: function (req, file, cb) {
        var datetimestamp = Date.now();
        cb(null, file.fieldname + '-' + datetimestamp + '.' + file.originalname.split('.')[file.originalname.split('.').length -1])
    }
});

var upload = multer({
    storage: storage,
    fileFilter : function(req, file, callback) { //file filter
        if (['xls', 'xlsx'].indexOf(file.originalname.split('.')[file.originalname.split('.').length-1]) === -1) {
            return callback(new Error('Wrong extension type'));
        }
        callback(null, true);
    }
}).single('file');

//----------------------------test-functions---------------------

function test(){
    fs.createReadStream(__dirname + "/public/" + 'calls.csv').pipe(csv()).on('data', (r) => {
	parse_row(r);
	console.log(r);
    }).on('end', () => {
	console.log('CSV file successfully processed');
    });
}

// //----------------------------app-endpoints--------------------------

app.get('/health-check', (req, res) => res.sendStatus(200));

app.get('/csv', function (req, res) {
    fs.createReadStream(__dirname + "/public/" + 'calls.csv').pipe(csv()).on('data', (r) => {
	parse_row(r);
	console.log(r);
    }).on('end', () => {
	console.log('CSV file successfully processed');
    });
});

app.post('/upload', function(req, res) {
    var exceltojson;
    upload(req,res,function(err){
        if(err){
            res.json({error_code:1,err_desc:err});
            return;
        }
        if(!req.file){
	    return res.send('No file passed, <a href="index.html"> restart </a>');
        }
        if(req.file.originalname.split('.')[req.file.originalname.split('.').length-1] === 'xlsx'){
            exceltojson = xlsxtojson;
        } else {
            exceltojson = xlstojson;
        }
        try {
            exceltojson({
                input: req.file.path,
                output: null, //since we don't need output.json
                lowerCaseHeaders:true
            }, function(err,result){
                if(err) {
                    //res.json({error_code:1,err_desc:err, data: null});
		    res.writeHead(200, { 'Content-Type': 'text/html' });
		    res.write(err);
		    return res.end();
                    //res.write({error_code:1,err_desc:err, data: null});
                }
		console.log('parsing');
		for(r in result){
		    var row = result[r];
		    console.log(row);
		    parse_row(row);
		}
                //res.json({error_code:0,err_desc:null, data: result});
		return res.sendFile( __dirname + "/public/" + "success.html" );
            });
        } catch (e){
            res.json({error_code:1,err_desc:"Corupted excel file"});
        }
    })
});

function proxyFile(req,res){
    if(req.url === "/"){
        fs.readFile("./public/index.html", "UTF-8", function(err, html){
            res.writeHead(200, {"Content-Type": "text/html"});
            res.end(html);
        });
    }else if(req.url.match("\.css$")){
        var cssPath = path.join(__dirname, 'public', req.url);
        var fileStream = fs.createReadStream(cssPath, "UTF-8");
        res.writeHead(200, {"Content-Type": "text/css"});
        fileStream.pipe(res);
    }else if(req.url.match("\.js$")){
        var cssPath = path.join(__dirname, 'public', req.url);
        var fileStream = fs.createReadStream(cssPath, "UTF-8");
        res.writeHead(200, {"Content-Type": "application/javascript"});
        fileStream.pipe(res);
    }else if(req.url.match("\.png$")){
        var imagePath = path.join(__dirname, 'public', req.url);
        var fileStream = fs.createReadStream(imagePath);
        res.writeHead(200, {"Content-Type": "image/png"});
        fileStream.pipe(res);
    }else{
        res.writeHead(404, {"Content-Type": "text/html"});
        res.end("No Page Found");
    }
}

app.get('/*', function (req, res) {
    res.sendFile( __dirname + "/public/" + "index.html" );
})


var httpServer = http.createServer(app)
httpServer.listen(process.env.PORT);

var httpsServer = https.createServer(cred, app);
httpsServer.listen(process.env.PORT_SSL
		   ,function(){
		       var host = httpsServer.address().address;
		       var port = httpsServer.address().port;
		       console.log("Exaple app listening at http://%s:%s", host, port);		   
		   });

