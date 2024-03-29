//var app;
var tmp = "";
var scheda = {
    baseUrl: "",
    lastId: 1,
    lastIdOff: 1,
    sData: {id: "", date: ""},
    init: function(url){
	baseUrl = url;
    },
    lettore: function(){
	var url = baseUrl + 'odata.php?callback=?';
	$.ajax({
	    type: 'GET',
	    url: url,
	    async: false,
            crossDomain: true,          
	    //	    jsonpCallback: 'jsonCallback',
	    contentType: "application/json",
	    dataType: 'jsonp',
	    //	    jsonp: 'callback',
	    success: function(json) {
		//console.dir(json);
	    },
	    error: function(e) {
		//console.log(e.message);
	    }
	});
    },
    li_element: function(sData){
	var listIt = '<li class="coupon-element" data-theme="c" data-transition="slide">';
	for(var j in sData){
	    listIt += sData[j]['name'] + ": " + sData[j]['value'] + ", ";
	}
	listIt += '<\/li>';
	return listIt;
    },
    recuperatore: function(){
	var elencoSchede = $("#liElencoSchede");
	elencoSchede.html("");
	$("#listIt").html('');
	$('#btnAggiornatore').css("display","none");
	var isData = 0;
	for(var i=0; i<app.storage.length; i++){
	    var key = app.storage.key(i);
	    if(key.match(/record_/g)){
		isData = 1;
		var li = $("<li data-theme='c'><a href='#' data-transition='slide'>" + key + "</a></li>");
		li.on("tap",function (){
		    var value = app.storage.getItem($(this).text());
		    var sData = JSON.parse(JSON.parse(value));
		    console.log(sData);
		    $('#listIt').html(scheda.li_element(sData));
		});
		li.on("taphold",function(){
		    var key = $(this).text();
		    var r = confirm("Conferm record deletion?");
		    if(r==true){
			scheda.cancellore(key);
			$.mobile.navigate("#homePage");
		    }
		});
	    elencoSchede.append(li);
	    }
	    //elencoSchede.listview("refresh");
	}
	if(isData){
	    $("#btnAggiornatore").html("Publish online");
	    $('#btnAggiornatore').css("display","block");
	}
	else{
	    elencoSchede.html("No records");
	}
    },
    listoreOff: function(){
	for (var i=0; i<app.storage.length; i++) {
	    var key = app.storage.key(i);
	    if(key.match(/record_/g)){
		scheda.lastIdOff = ++i;
		// scheda.lastIdOff = parseInt(scheda.lastIdOff) + 1;
	    }
	}
    },
    listore: function(){
	app.storage.removeItem("addetto");
	app.storage.removeItem("pullman");
	app.storage.removeItem("pulizia");
	var addArr = [];
	var busArr = [];
	var pulArr = [];
	$.getJSON(
	    baseUrl + "odata.php?callback=?",
	    {format: "jsonp"},
	    function( data ) {
		$.each(data, function(i,el) {
		    if(el.type == "addetto"){
			var entry = {
			    "name" : el.name,
			};
			addArr.push(el.name);
		    }
		    if(el.type == "pullman"){
			busArr.push(el.name);
		    }
		    if(el.type == "pulizia"){
			pulArr.push(el.name);
		    }
		    if(el.type == "id"){
			scheda.lastId = parseInt(el.last_id) + 1;
		    }
		});
		app.storage.setItem("addetto",JSON.stringify({addArr: addArr}));
		app.storage.setItem("pullman",JSON.stringify({busArr: busArr}));
		app.storage.setItem("pulizia",JSON.stringify({pulArr: pulArr}));
	    });
    },
    aggiornatore: function() {
	var r = confirm("Confermi l'invio delle schede?");
	if(r==true){
	    scheda.mandatoreLinea();
	    //scheda.resettore();
	    scheda.recuperatore();
	}
    },
    mandatorePacchetto: function(){
	var listaSchede = [];
	for (var i=0; i<app.storage.length; i++) {
	    var key = app.storage.key(i);
	    if(key.match(/record_/g)){
		var value = app.storage.getItem($.trim(key));
		scheda.sData = JSON.parse(value);
		listaSchede.push(scheda.sData);
	    }
	}
	scheda.inviatore(
	    listaSchede,
	    function() {
		//alert("inviato");
	    },
	    function() {
		alert("non inviato");
	    });
    },
    mandatoreLinea: function(){
	for (var i=0; i<app.storage.length; i++) {
	    var key = app.storage.key(i);
	    if(key.match(/record_/g)){
		var value = app.storage.getItem($.trim(key));
		scheda.sData = JSON.parse(value);
		var sent = scheda.inviatoreLinea(scheda.sData,key);
	    }
	}
    },
    inviatoreLinea: function(sData,key){
	//alert(sData);
	tmp = sData;
	var request = $.ajax({
	    //url: baseUrl + "lib/db.php?callback=?",
	    url: baseUrl + "lib/db.php",
	    type: "POST",
	    //async: false,
            crossDomain: true,          
	    //	    jsonpCallback: 'jsonCallback',
	    contentType: "application/json; charset=utf-8",
	    dataType: 'json',//p',
	    //jsonp: 'callback',
	    //data: {"record":JSON.stringify(sData)},
	    data: sData,
	    success: function(data){alert(data);},
	    failure: function(errMsg){alert(errMsg);}
	});
	//console.log(request);
	request.done(function( msg ) {
	    app.storage.removeItem(key);
	    return 1;
	    //alert(msg);
	});
	request.fail(function( jqXHR, textStatus ) {
	    return 0;
	    //alert("non salvato (" + textStatus + ")");
	});
    },
    inviatorePacchetto: function(listaSchede, successCallback, failCallback) {
	//console.log(listaSchede);
	$.ajax({
	    url: scheda.baseUrl + "idata.php",
	    type: "POST",
	    data: listaSchede})
	    .done(function() {app.storage.clear(); successCallback();})
	    .fail(failCallback);
    },
    salvatore: function(){
	var formData = JSON.stringify($("#patientForm").serializeArray());
	scheda.lastIdOff++;
	var key = "record_" + scheda.lastIdOff;
	//app.storage.setItem(key, JSON.stringify(formData));
	app.storage.setItem(key, JSON.stringify(formData));
	scheda.selettoreOffline();
	//alert("salvato " + scheda.sData.id);
	//$.mobile.navigate("#homePage");
    },
    caricatore: function(key){
	if(key.match(/record_/g)){
	    var value = app.storage.getItem($.trim(key));
	    scheda.sData = JSON.parse(value);
	}
    },
    cancellore: function(key){
	if(key != "") {
	    app.storage.removeItem($.trim(key));
	}
    },
    cancelloreSql: function(key){
	var query = "";
	var table = "wa_pulito";
	query += "DELETE FROM " + table + " WHERE " + table + ".id = " + key + ";";
	var options = "";
	//alert(query);
	var request = $.ajax({
	    type: "POST",
	    url: baseUrl + "idata.php?callback=?" + options,
	    async: false,
            crossDomain: true,          
	    //jsonpCallback: 'jsonCallback',
	    contentType: "application/json",
	    dataType: 'jsonp',
	    //jsonp: 'callback',
	    data: {'query' : query},
	});
	request.done(function( msg ) {
	    //alert(msg);
	});
	request.fail(function( jqXHR, textStatus ) {
	    //alert("non salvato (" + textStatus + ")");
	});
	//window.location.reload();
	$.mobile.navigate("#homePage");
    },
    resettore: function(){
	var r = confirm("Confermi cancellazione schede?");
	if(r==true){
	    for(var i=0; i<app.storage.length; i++){
		var key = app.storage.key(i);
		if(key.match(/record_/g)){
		    app.storage.removeItem(key);
		}
	    }
	}
    },
    inseritore: function(){
	var formData = JSON.stringify($("#patientForm").serializeArray());
	// var menuId = $( "ul.nav" ).first().attr( "id" );
	var request = $.ajax({
	    //url: baseUrl + "odata.php?callback=?" + options,
	    url: baseUrl + "lib/db.php?callback=?",
	    type: "POST",
	    async: false,
            crossDomain: true,          
	    //jsonpCallback: 'jsonCallback',
	    contentType: "application/json",
	    dataType: 'jsonp',
	    jsonp: 'callback',
	    data: {'query' : formData},
	});
	request.done(function( msg ) {
	    //alert(msg);
	});
	request.fail(function( jqXHR, textStatus ) {
	    //alert("non salvato (" + textStatus + ")");
	});
	//window.location.reload();
	$.mobile.navigate("#homePage");
    },
    selettore: function(){
	var addSelector = "";
	var busSelector = "";
	var pulSelector = "";
	var idSelector = "";
        $.getJSON(
	    baseUrl + "odata.php?callback=?",
	    {format: "jsonp"},
	    function( data ) {
		$.each(data, function(i,el) {
		    if(el.type == "addetto"){
			addSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		    if(el.type == "pullman"){
			busSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		    if(el.type == "pulizia"){
			pulSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		    if(el.type == "id"){
			var last_id = parseInt(el.last_id) + 1;
			idSelector = last_id;
		    }
		});
		var sel = '<div data-role="fieldcontain"><select id="PAddetto" name="PAddetto" class="selectClass" required><option value="">scegli addetto<\/option>' + addSelector + '<\/select><\/div>';
		sel += '<div class="selectClass"> manutenzione: <input type="checkbox" name="PManutenzione" id="PManutenzione" value="0"/><br>';
		sel += '<div data-role="fieldcontain"><select id="PPullman" name="PPullman" class="selectClass" required><option value="" >scegli pullman<\/option>' + busSelector + '<\/select><\/div>';
		sel += '<div data-role="fieldcontain"><select id="PPulizia" name="PPulizia" class="selectClass" required><option value="" > pulizia <\/option>' + pulSelector + '<\/select><\/div>';
		sel += '<div data-role="fieldcontain"><div id="PId" class="idClass">' + idSelector + '</div></div>';
		sel += '<div data-role="fieldcontain" class="selectClass"> Giorno: <input type="text" id="PDate" class="data-attivita" name="PDate" size="15" value="" required/></input></div>';
		$("#selettore").html(sel);
		$.mobile.changePage($("#scheda"));
		$("#selettore").html(sel);
		app.today();
	    });
    },
    createForm: function(fieldL){
	var sel = '<form action="patientUrl" method="POST" name="patientForm" id="patientForm">';
	for(var k in fieldL){
	    var g = fieldL[k];
	    if(!(g['active'])){continue;}
	    if(g['type'] === 'multiple'){
		var addSelector = "";
		var f = g['values'];
		for(var j in f){
		    addSelector += '<option value="'+f[j]+'">'+f[j]+'<\/option>';
		}
		sel += '<div data-role="fieldcontain"><select id="'+g['key']+'" name="'+g['placeholder']+'" placeholder="'+g['placeholder']+'" class="selectClass"><option value="" > '+g['placeholder']+'<\/option>' + addSelector + '<\/select><\/div>\n';
	    }
	    else if(g['type'] === 'date'){
		sel += '<div data-role="fieldcontain" class="selectClass">';
		sel += '' + g['placeholder'] + '';
		sel += '<input type="date" id="'+g['key']+'"value="'+g['placeholder']+'"><\/input>';
		sel += '<\/div>\n';
	    }
	    else if(g['type'] === 'check'){
		sel += '<div data-role="fieldcontain" class="selectClass">'+g['placeholder']+'<input type="checkbox" id="'+g['key']+'" name="'+g['placeholder']+'"><\/input><\/div>\n';
	    }
	    else{
		sel += '<div data-role="fieldcontain"><input type="text" id="'+g['key']+'" name="'+g['placeholder']+'" placeholder="'+g['placeholder']+' "class="selectClass"><\/input><\/div>\n';
	    }
	}
	sel += '</form>';
	return sel;
    },
    selettoreOffline: function(){
	var request = $.ajax({
	    //url: baseUrl + "odata.php?callback=?" + options,
	    url: baseUrl + "lib/scheme.php",
	    type: "GET",
            crossDomain: true,          
	    //jsonpCallback: 'jsonCallback',
	    success: function(data){
		var d = JSON.parse(data);
		fieldL = d['fields'];
		var sel = scheda.createForm(fieldL);
		//$("#selettoreOffline").html(sel);
		$.mobile.changePage($("#salvatore"));
		$("#selettoreOffline").html(sel);
		app.today();
	    },
	    failure: function(errMsg){
		//alert(errMsg);
		$.getJSON("data/patientForm.json", function(data){
		    fieldL = data['fields'];
		    var sel = scheda.createForm(fieldL);
		    //$("#selettoreOffline").html(sel);
		    $.mobile.changePage($("#salvatore"));
		    $("#selettoreOffline").html(sel);
		    app.today();
		});
	    }
	});
	//window.location.reload();
    },
    selettore1: function(){
	var addSelector = "";
	var busSelector = "";
	var pulSelector = "";
        $.getJSON(
	    baseUrl + "odata.php?callback=?",
	    {format: "jsonp"},
	    function( data ) {
		$.each(data, function(i,el) {
		    if(el.type == "addetto"){
			addSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		    if(el.type == "pullman"){
			busSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		    if(el.type == "pulizia"){
			pulSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		});
		var sel = '<div data-role="fieldcontain"><select id="SAddetto" name="SAddetto" class="selectClass"><option value="" > addetto tutti<\/option>' + addSelector + '<\/select><\/div>';
		sel += '<div data-role="fieldcontain"><select id="SPullman" name="SPullman" class="selectClass"><option value="" > pullman tutti<\/option>' + busSelector + '<\/select><\/div>';
		sel += '<div data-role="fieldcontain"><select id="SPulizia" name="SPulizia" class="selectClass"><option value="" > pulizia tutti<\/option>' + pulSelector + '<\/select><\/div>';
		$("#selettore1").html(sel);
		$.mobile.changePage($("#elencoSchede"));
		$("#selettore1").html(sel);

	    });
    },
    visore: function(){
	var visore = $("#visore");
	visore.html('<ul id="liElencoSchede" class="coupon-list" data-role="listview" data-divider-theme="d" data-inset="true">');
	var addSelector = "";
	var options="";
	var addetto = $("#SAddetto").val();
	var pullman = $("#SPullman").val();
	var pulizia = $("#SPulizia").val();
	if(addetto != 'undefined'){
	    options += "&addetto="+addetto;
	}
	if(pullman != 'undefined'){
	    options += "&pullman="+pullman;//.replace(" ","+");
	}
	if(pulizia != 'undefined'){
	    options += "&pulizia="+pulizia;
	}
        $.getJSON(
	    baseUrl + "odata.php?storico=1&callback=?" + options,
	    {format: "jsonp"},
	    function( data ) {
		// console.log(data);
		$.each(data, function(i,el) {
		    var li = $('<li class="coupon-element" data-theme="c" data-transition="slide">' + el.id + ") " + el.addetto + " pulì il " + el.pullman + " con " + el.pulizia + " il " + el.data + '<\/li>');
		    li.on("taphold",function (){
			var key = el.id;
			var r = confirm("Confermi eliminazione scheda?");
			if(r==true){
			    scheda.cancelloreSql(key);
			    $.mobile.navigate("#lettore");
			}
		    });
		    visore.append(li);
		});
	    });
	visore.append('<\/ul>');
    },
    selettore2: function(){
	var addSelector = "";
	var busSelector = "";
	var pulSelector = "";
        $.getJSON(
	    baseUrl + "odata.php?callback=?",
	    {format: "jsonp"},
	    function( data ) {
		$.each(data, function(i,el) {
		    if(el.type == "addetto"){
			addSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		    if(el.type == "pullman"){
			busSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		    if(el.type == "pulizia"){
			pulSelector += '<option value="' + el.name + '" > ' + el.name + '<\/option>';
		    }
		});
		var sel = '<div data-role="fieldcontain"><select id="CAddetto" name="CAddetto" class="selectClass" ><option value="" > cambia addetto <\/option>' + addSelector + '<\/select><\/div>';
		sel += '<div data-role="fieldcontain"><select id="CPullman" name="CPullman" class="selectClass" ><option value="" > cambia pullman <\/option>' + busSelector + '<\/select><\/div>';
		sel += '<div data-role="fieldcontain"><select id="CPulizia" name="CPulizia" class="selectClass"><option value="" > cambia pulizia<\/option>' + pulSelector + '<\/select><\/div>';
		$("#selettore2").html(sel);
	    });
    },
    selettore3: function(){
	var bus_id = 0;
	var add_id = 0;
	var pul_id = 0;
        $.getJSON(
	    baseUrl + "odata.php?callback=?",
	    {format: "jsonp"},
	    function( data ) {
		$.each(data, function(i,el) {
		    if(el.type == "addetto"){
			add_id = parseInt(el.id);
		    }
		    if(el.type == "pullman"){
			bus_id = parseInt(el.id);
		    }
		    if(el.type == "pulizia"){
			pul_id = parseInt(el.id);
		    }
		});
		add_id += 1;
		bus_id += 1;
		var cre = '<div data-role="fieldcontain"><select id="AType" name="AType" class="selectClass" required><option value="addetto" >addetto<\/option><option value="pullman" >pullman<\/option><option value="pulizia" >pulizia<\/option><\/select>nome:<input id="AName"></input> <div id="AIdAdd" class="IdClass">' + add_id + '</div><div id="AIdBus" class="IdClass">' + bus_id + '</div><div id="AIdPul" class="IdClass">' + pul_id + '</div><\/div>';
		$("#creatore").html(cre);
	    });
    },
    selettore4: function(){
	var cre = '<div data-role="fieldcontain"><input id="LUser" name="LUser" placeholder="utente"></input><input id="LPass" name="LPass" placeholder="password"></input></div>';
	$("#selettore4").html(cre);
    },
    selezionatore: function(){
	var addSelector = "";
	var options="";
	var addetto = $("#CAddetto").val();
	var pullman = $("#CPullman").val();
	var pulizia = $("#CPulizia").val();
        $.getJSON(
	    baseUrl + "odata.php?callback=?" + options,
	    {format: "jsonp"},
	    function( data ) {
		$.each(data, function(i,el){
		    if(el.name == addetto){
			addSelector = '<div id="CType" class "selectClass">addetto</div> nome:<input id="CName" value="'+el.name+'"></input> id: <div id="CId"  class="idClass"">'+el.id+'</div>';
		    }
		    if(el.name == pullman){
			addSelector = '<div id="CType" class "selectClass">pullman</div>nome:<input id="CName" value="'+el.name+'"></input> id: <div id="CId"  class="idClass">'+el.id+'</div>';
		    }
		    if(el.name == pulizia){
			addSelector = '<div id="CType" class "selectClass">pulizia</div>nome:<input id="CName" value="'+el.name+'"></input> id: <div id="CId"  class="idClass">'+el.id+'</div>';
		    }
		});
		addSelector = '<div data-role="fieldcontain">' + addSelector + '<\/div>';
		$("#selezionatore").html(addSelector);
	    });
    },
    filore:function(){
	var options = "&file=1";
	$.getJSON(
	    baseUrl + "odata.php?callback=?" + options,
	    {format: "jsonp"},
	    function( data ) {
	    });
  	window.open(baseUrl + "FormResume.csv", "_system");
    },
    cambiatore: function(event){
	var change = event.data.change;
	var name = $("#CName").val();
	var type = $("#CType").text();
	var id = $("#CId").text();
	var query = "";
	var table = "wa_" + type;
	if(change == 0){
	    query += "UPDATE " + table + " SET name = '" + name + "' WHERE " + table + ".id = " + id + ";";
	}
	if(change == 1){
	    query += "DELETE FROM " + table + " WHERE " + table + ".id = " + id + ";";
	}
	if(change == 2){
	    name = $("#AName").val();
	    table = "wa_" + $("#AType").val();
	    id = $("#AIdAdd").text();
	    if(type == "pullman"){ id = $("AIdBus").text();}
	    if(type == "pulizia"){ id = $("AIdPul").text();}
	    query += "INSERT INTO " + table + " (id,name) VALUES ('" + id + "','" + name + "');"
	}
	var options = "";
	//alert(query);
	var request = $.ajax({
	    type: "POST",
	    url: baseUrl + "idata.php?callback=?" + options,
	    async: false,
            crossDomain: true,          
	    //	    jsonpCallback: 'jsonCallback',
	    contentType: "application/json",
	    dataType: 'jsonp',
	    //	    jsonp: 'callback',
	    data: {'query' : query},
	});
	request.done(function( msg ) {
	    //alert(msg);
	});
	request.fail(function( jqXHR, textStatus ) {
	    //alert("non salvato (" + textStatus + ")");
	});
	//window.location.reload();
	$.mobile.navigate("#homePage");
    },
}
