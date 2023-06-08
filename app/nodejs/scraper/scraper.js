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
var baseUrl = "http://dauvi.org"
var headerD = headL['header1']
var cook = cookL[Object.keys(cookL).find(key => cookL[key]['name'] === '1P_JAR')]
var csv = require('csv');
var parse = require('csv-parse')
var obj = csv();
var poiL = [];
var fileData = fs.readFileSync('../../raw/tank/poi.csv','utf-8')
var dataArray = fileData.split(/\r?\n/);
for(let i=0;i<dataArray.length;i++){poiL.push(dataArray[i].split(",")[1])}
function onlyUnique(value, index, self) {return self.indexOf(value) === index;}
var poiL = poiL.filter(function(value,index,self){return self.indexOf(value) === index});

var webdriver = require('selenium-webdriver');
var browser = new webdriver.Builder().usingServer().withCapabilities({'browserName':'firefox'}).build();
//var driver = new webdriver.Builder().forBrowser('firefox').setFirefoxOptions( /* … */).build();
//    .setProxy(proxy.manual({http: '127.0.0.1:9000'}))

browser.get(baseUrl);
var labL = null;
var pathS = "//div[@class='section-popular-times-bar section-popular-times-bar-with-label']";
var pathS = "//div[@class='section-popular-times-value']";
var pathS = "//div[@aria-label=*]";
var pathS = "//div[@class='section-popular-times-bar']";

async function parseSearch(poiL){
    var pathS = "//div[@class='section-popular-times-bar']";
    await browser.get("https://www.google.com/maps")
    for(let k=1;k<poiL.length;k++){
    //for(let k=1;k<3;k++){
	console.log(k," ",poiL[k])
	cK = k
	await searchPoi('Rastätte ' + poiL[k])
	await browser.sleep(1000*Math.random())
	await browser.getCurrentUrl().then(function(x){parseSingle(x,pathS)})
	await browser.sleep(1000*Math.random())
    }
}
parseSearch(poiL)


var el = browser.findElement(webdriver.By.name('q'))
el.clear()
searchQ = 'Rastätte ' + poiL[cK]
el.sendKeys(searchQ, webdriver.Key.RETURN)

browser.wait(webdriver.until.titleIs(searchQ + ' - Google Maps'), 1000)
browser.findElements(webdriver.By.xpath("//div[@class='section-result']")).then(function(elements){if(elements.length > 1){elements[0].click()}})
browser.getCurrentUrl().then(function(x){parseSingle(x,pathS)})



browser.getCurrentUrl().then(function(x){parseSingle(x,pathS)})


