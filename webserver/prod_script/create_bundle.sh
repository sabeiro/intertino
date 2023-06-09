bundleN=$(pwd | awk -F "/" '{ print $NF}')
zip ../$bundleN.zip -r * .[^.]*
