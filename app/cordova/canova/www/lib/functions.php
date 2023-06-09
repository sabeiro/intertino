<?php


// calcola la distanza tra due punti (haversine formula, vedi http://www.movable-type.co.uk/scripts/latlong.html)
function calculateDistance($lat1, $lat2, $lng1, $lng2)
{
	try {
		if(!$lat1 || !$lng1 || !$lat2 || !$lng2 || $lat1=='undefined' || $lng1=='undefined' || $lat2=='undefined' || $lng2=='undefined')
			return "n/d";

		$radius = 6371; // km
		$dLat = deg2rad($lat2-$lat1);
		$dLon = deg2rad($lng2-$lng1);
		$lat1 = deg2rad($lat1);
		$lat2 = deg2rad($lat2);

		$a = sin($dLat/2) * sin($dLat/2) + sin($dLon/2) * sin($dLon/2) * cos($lat1) * cos($lat2); 
		$c = 2 * atan2(sqrt($a), sqrt(1-$a));
		$d = $radius * $c;

		return number_format(floatval($d), 1, ',', '.');
	}
	catch(Exception $e) { return "n/d"; }
}



// formatta in tabella i partecipanti ad un evento
function displayAttendees($attArray, $userPerRow=10)
{
	$html = '<table class="attendees">
	<tr><th colspan="'.$userPerRow.'">Partecipanti (<span class="num">'.count($attArray).'</span> fino ad ora):</th></tr>';
	$i = 0;
	foreach($attArray as $att)
	{
		if($i%$userPerRow == 0)
			$html .= '<tr>';

		$html .= '<td><a href="http://www.facebook.com/'.$att["uid"].'" target="_blank"><img src="'.$att["pic_square"].'" alt="'.$att["name"].'"></a></td>';

		if($i%$userPerRow == ($userPerRow-1))
			$html .= '</tr>';

		$i++;
	}

	$html .= "</table>";
	return $html;
}



// =================================================================
//	FUNZIONI DI SUPPORTO URL
// =================================================================


// crea l'url per l'evento (SEO)
function slug($string, $slug = '-', $extra = null)
{
	return strtolower(trim(preg_replace('~[^0-9a-z' . preg_quote($extra, '~') . ']+~i', $slug, unaccent($string)), $slug));
}

function unaccent($string)
{
	if (strpos($string = htmlentities($string, ENT_QUOTES, 'UTF-8'), '&') !== false)
	{
		$string = html_entity_decode(preg_replace('~&([a-z]{1,2})(?:acute|caron|cedil|circ|grave|lig|orn|ring|slash|tilde|uml);~i', '$1', $string), ENT_QUOTES, 'UTF-8');
	}

	return $string;
}






?>
