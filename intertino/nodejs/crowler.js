var fs = require('fs');
var sys = require('util');
var parser = require("htmlparser2");
var request = require('request');
var cheerio = require('cheerio');
var cred = JSON.parse(fs.readFileSync(process.env.LAV_DIR + 'credenza/geomadi.json', 'utf8'));
var cookL = JSON.parse(fs.readFileSync('google-cookies.json', 'utf8'))['cookies'];
var urlL = JSON.parse(fs.readFileSync('url_list.json', 'utf8'));
var headL = JSON.parse(fs.readFileSync('header_list.json', 'utf8'));
var request = require('request');
var baseUrl = 'https://www.populationpyramid.net/'

var headerD = headL['header1']
var cook = cookL[Object.keys(cookL).find(key => cookL[key]['name'] === '1P_JAR')]
var csv = require('csv');
var parse = require('csv-parse')
var System = require("system")

var webdriver = require('selenium-webdriver');
var browser = new webdriver.Builder().usingServer().withCapabilities({'browserName':'firefox'}).build();
var country = 'germany'
browser.get(baseUrl + country);
var pyram = {'germany':{}}
function array2file(elements){
    if(elements.length == 0){console.log("no curve found")}
    var labL = new Array();
    for(let i=0; i<elements.length; i++){elements[i].getText().then(function(val){
	labL.push(val)
    })}
    return labL
}
browser.findElements(webdriver.By.className('malePercentage')).then(function(el){
    pyram[country]['male'] = array2file(el);
});
browser.findElements(webdriver.By.className('femalePercentage')).then(function(el){
    pyram[country]['female'] = array2file(el);
});
browser.findElements(webdriver.By.css(".pp-y-axis > .tick")).then(function(el){
    pyram[country]['variable'] = array2file(el);
    pyram[country]['variable'] = pyram[country]['variable'].slice(0,-1)
})
browser.sleep(1000*Math.random())
fs.writeFile(process.env.LAV_DIR+'raw/basics/census.json',JSON.stringify(pyram),'utf8',function(err){if(err){console.log(err);} else {console.log("saved");}});

