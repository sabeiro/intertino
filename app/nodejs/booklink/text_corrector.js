import express from 'express';
import helmet from 'helmet';
import $ from "jquery";
import request from 'request';
import http from 'http';
import dotenv from 'dotenv';
import path from 'path';

let header = {"Authorization":"Bearer " + process.env.OPENAI_KEY}
const call_options = {
  url: 'https://api.openai.com/v1/chat/completions',
  json: true, headers: header, body: {}
}

const app = express();
const endpoint = '/correct/';
app.use(express.json());
app.set('view engine', 'ejs');
// app.use(express.static('views')); //Serves resources from public folder
app.use(endpoint, express.static('views'));

const scriptSources = ["'self'","'unsafe-inline'","'unsafe-eval'","https://cdnjs.cloudflare.com","https://cdn.jsdelivr.net"];
const styleSources = ["'self'","'unsafe-inline'","https://cdn.jsdelivr.net"];

app.use(
  helmet.contentSecurityPolicy({
// 	useDefaults:false,"block-all-mixed-content":true,"upgrade-insecure-requests":true,
	directives: {
      "defaultSrc": ["'self'"],
      "scriptSrc": scriptSources,
      "scriptSrcElem": scriptSources,
      "styleSrc": styleSources,
	  "img-src":["'self'"],
	}
  })
);
app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false,
  })
);
//   helmet.dnsPrefetchControl({allow: true}),
//   helmet.frameguard({action: "deny"}),
//   helmet.hidePoweredBy(),
//   helmet.hsts({maxAge: 123456,includeSubDomains: false}),
//   helmet.ieNoOpen(),helmet.noSniff(),
//   helmet.referrerPolicy({policy: [ "origin", "unsafe-url" ]}),
//   helmet.xssFilter()

// app.use(function(req, res, next) {
//   res.header("Access-Control-Allow-Origin", "*");
//   res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
//   next();
// });

app.get(endpoint, function(req, res) {
  var mascots = [
    { name: 'Headline', description: "Be clear"},
    { name: 'Style', description: "focus on the main topics"},
    { name: 'Incisive', description: "express your value proposition"}
  ];
  var tagline = "Corrections can be style or content.";
  res.render('index', {mascots: mascots, tagline: tagline});
});

app.get(endpoint + 'about', function(req, res) {
  res.render('about');
});

app.get(endpoint + 'editor', function(req, res) {
  res.render('pages/editor');
});

app.post(endopoint + 'call', function(req, res) {
  call_options.body = req.body;
  request.post(call_options, (err, resp, body) => {
	if (err) {return console.log(err)}
	console.log(`Status: ${res.statusCode}`)
	console.log(body)
	res.json(body);
  })
});

app.listen(3000, function(){
    console.log('Server is running on port 3000.')
})

