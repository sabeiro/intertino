var labV = [];
var occTime = [];
var d = 0;
var h1 = "";
document.querySelectorAll('.section-popular-times-value').forEach(function (labL, index) {
    var lab = labL.parentNode.attributes['aria-label'].nodeValue;
    occTime.push(lab)
    var labS = lab
    var c = labS[0]
    var h = d.toString() + "-" + labS[1].split("at ")[1]
    labV[h] = c
    if(h.match('AM') && h1.match('PM')){
	d = d+1;
    }
    h1 = h;
});
copy(occTime);

