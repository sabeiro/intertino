var YQL = require("yql");
 
new YQL.exec('select * from data.html.cssselect where url="http://tilomitra.com/repository/screenscrape/ajax.html" and css="#content"', function(response) {
 
    //This will return undefined! The scraping was unsuccessful!
    console.log(response.results);
 
});
