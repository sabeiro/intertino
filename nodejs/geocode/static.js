var express = require('express');
var app = express();

//setting middleware
app.use(express.static(__dirname + 'public')); //Serves resources from public folder
app.use(express.static('public')); //Serves resources from public folder

app.get('/', function(req, res){
    console.log('ciccia');
});


var server = app.listen(5000);
