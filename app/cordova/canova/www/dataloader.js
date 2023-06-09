var defaultLat = 45.569206;
var defaultLng = 10.62579;
var minZoomLevel = 12;
var baseUrl = 'http://www.ilocalidelgarda.it/';
var baseUrl = '../../../';

// GESTISCE IL CARICAMENTO DELLA MAPPA
$(document).on('pageshow', '#map', function (event) {
    max_height();
    $('#map_canvas').gmap({'disableDefaultUI':true, 'zoom':10, 'center':new google.maps.LatLng(defaultLat, defaultLng), 'callback': function() {
	var self = this;
	var imagetoday = {
	    url: 'img/mapicon.png',
	    size: new google.maps.Size(38, 36),
	    origin: new google.maps.Point(0,0),
	    anchor: new google.maps.Point(0, 36)
	};
	var imageweek = {
	    url: 'img/mapicon_grey.png',
	    size: new google.maps.Size(38, 36),
	    origin: new google.maps.Point(0,0),
	    anchor: new google.maps.Point(0, 36)
	};
	var imageevidence = {
	    url: 'img/mapicon_evidence.png',
	    size: new google.maps.Size(44, 42),
	    origin: new google.maps.Point(0,0),
	    anchor: new google.maps.Point(0, 42)
	};

	self.refresh();

	self.getCurrentPosition(function(position, status) {
//	    if ( status === 'OK' ) 
{
		$('#map_canvas').gmap('option', 'center', new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
		self.set('clientPosition', new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
		self.addMarker({'position': self.get('clientPosition'), 'bounds': false});
		self.addShape('Circle', { 'strokeWeight': 0, 'fillColor': "#008595", 'fillOpacity': 0.25, 'center': self.get('clientPosition'), 'radius': 15, clickable: false });
    position.coords.longitude = defaultLng;
    position.coords.latitude = defaultLat;
	    }
	});
	$.getJSON(baseUrl+'data.php', function(data) {
	    $('.maploader').hide();
	    $.each(data.markers, function(i,el) {
		self.addMarker({'id': el.id, 'tags':el.tags, 'position': new google.maps.LatLng(el.lat, el.lng), 'icon':(el.evidence=="1" ? imageevidence : (el.tags=='today' ? imagetoday : imageweek)), 'z-index':(el.evidence=="1" ? "999":(el.tags=='today' ? "99" : "9")), 'bounds':false }, function(map,marker) {
		    $(el).click(function() {
			$(marker).triggerEvent('click');
		    });
		}).click(function() {
		    self.openInfoBox(displayContent(el), this);
		});
	    });
	});
    }});
    $('#map_canvas').gmap('refresh');
});


// GESTISCE IL CARICAMENTO DELL'ELENCO
$(document).on('pageshow', '#list', function(event){
    if(event.handled !== true && $('.loader').is(':visible')) // This will prevent event triggering more then once
    {
	$.getJSON(baseUrl+'data.php?type=today', function(data) {
	    $('.loader').hide();
	    $.each(data.markers, function(i,el) {
		$("#eventlist").append("<li onclick='showDetails(\"detail"+el.id+"\","+el.id+"); return false;'><div class='image'><img src='"+ el.pic +"' /></div><div class='date'><span class='day'>"+ el.day +"</span><span class='month'>"+ el.month +"</span><span class='time'>"+ el.time +"</span></div><div class='title'>"+el.title+"</div><div class='location'>"+el.location+"</div><div id=\"detail"+el.id+"\" class='detail' style='display:none;'><span class='b-close'><span>X</span></span></div></li>");
	    });
	    $('#eventlist').listview().listview('refresh');
	    $('#loadtomorrow').show();
	    max_height();
	    event.handled = true;
	});
    }
    return false;
});


function max_height()
{
    var header = $.mobile.activePage.find("div[data-role='header']:visible");
    var footer = $.mobile.activePage.find("div[data-role='footer']:visible");
    var content = $.mobile.activePage.find("div[data-role='content']:visible:visible");
    var viewport_height = $(window).height();

    var content_height = viewport_height - header.outerHeight() - footer.outerHeight();
    if((content.outerHeight() - header.outerHeight() - footer.outerHeight()) <= viewport_height) {
	content_height -= (content.outerHeight() - content.height());
    } 
    $.mobile.activePage.find('[data-role="content"]').height(content_height);
}


function loadEvents(type, next)
{
    $('#load'+type).hide();
    $('.loader').show();

    $.getJSON(baseUrl+'/data.php?type='+type, function(data) {
	$('.loader').hide();
	$.each(data.markers, function(i,el) {
	    $("#eventlist").append("<li onclick='showDetails(\"detail"+el.id+"\","+el.id+"); return false;'><div class='image'><img src='"+ el.pic +"' /></div><div class='date'><span class='day'>"+ el.day +"</span><span class='month'>"+ el.month +"</span><span class='time'>"+ el.time +"</span></div><div class='title'>"+el.title+"</div><div class='location'>"+el.location+"</div><div id=\"detail"+el.id+"\" class='detail' style='display:none;'><span class='b-close'><span>X</span></span></div></li>");
	});

	$('#eventlist').listview().listview('refresh');
	if(next!='')
	    $('#load'+next).show();
	max_height();
    });
}


function displayContent(el)
{
    var iwcontent = "<div class='popup'><div class='date'><span class='day'>"+ el.day +"</span><span class='month'>"+ el.month +"</span><span class='time'>"+ el.time +"</span></div><a href='#' onclick='showDetails(\"detail"+el.id+"\","+el.id+"); return false;'><div class='title'>"+el.mobileTitle+"</div><div class='location'>"+el.location+"</div></a><div id=\"detail"+el.id+"\" class='detail' style='display:none;'><span class='b-close'><span>X</span></span></div></div>";

    var iwOptions = {
	content: iwcontent,
	disableAutoPan: false,
	maxWidth: 0,
	pixelOffset: new google.maps.Size(-132, 0),
	zIndex: null,
	boxStyle: { 
	    background: "url('img/tipbox.gif') no-repeat",
	    opacity: 1,
	    width: "250px"
	},
	closeBoxMargin: "0px", // 6px 4px 0px",
	closeBoxURL: "img/closebox.gif",
	infoBoxClearance: new google.maps.Size(1, 1),
	isHidden: false,
	pane: "floatPane",
	enableEventPropagation: false,
    };

    return iwOptions;
}


function showDetails(elem, eid)
{
    $('#'+elem).bPopup({
	content:'iframe', //'ajax', 'iframe' or 'image'
	speed:450,
	transition:'slideDown',
	scrollBar:true,
	loadUrl:baseUrl+'/p.php?eid='+eid //Uses jQuery.load()
    });
}

