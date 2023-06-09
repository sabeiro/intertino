<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
<link rel="stylesheet" href="js/jquery.mobile.min.css"/>
<script type="text/javascript" src="js/jquery.min.js"></script>
<script type="text/javascript" src="js/jquery.mobile.min.js"></script>
    <link rel="stylesheet" href="assets/style.css" />

  </head>

  <body>
    JSON Test Page.
    <div id = "events"></div>

    <script language="javascript">
$( ".inner" ).append( "<p>Test</p>" );
</script>
    <script language="javascript">
      var baseUrl = 'http://localidelgarda.it';
var baseUrl = '';
      var eventsHTML = '';
      var currLat;
      var currLng;
      var defaultLat = 45.569206;
      var defaultLng = 10.32915;//10.62579;
      $("#events").append("ciccia" + baseUrl+'data.php');


      $.getJSON(baseUrl+'data.php', function(data) {
      $("#events").append("qui ");
      $.each(data.markers.reverse(), function(i,el) {
      $("#events").append("franco ");
      $("#events").append("<div class='event'><div class='image'><img src='"+ el.pic +"' alt='"+el.title+"' /></div><div class='date'><span class='day'>"+ el.day +"</span><span class='month'>"+ el.month +"</span><span class='time'>"+ el.time +"</span></div><div class='title'>"+el.title+"</div><div class='location'>"+el.location+"</div><div class='description'>"+ el.desc +"</div><div class='more'><a href='#' onclick='showDetails(\"detail"+el.id+"\","+el.id+","+currLat+","+currLng+"); return false;' class=\"smallbutton\">Dettagli</a></div><div id='detail"+el.id+"' class='detail'><span class='b-close'><span>CHIUDI</span></span></div></div>");
      });
      });



    </script>

  </body>
</html>
