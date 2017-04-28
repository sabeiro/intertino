year=2017
fileL=$(xargs -a paliDateList$year.csv)
cat paliHeader.csv > paliViews.csv
for i in $fileL
do
	url="http://medianet.mediaset.it/datimktg/sas/aud/PDF_${i}/fasce.pdf"
	wget $url
	if [ ! -f "fasce.pdf" ]; then
		continue
	fi
	echo "------ $i ------"
	pdftotext fasce.pdf 
	sed '/^\s*$/d' fasce.txt | sed '/:/d' | sed '/[[:alpha:]]/d' | sed ':a;N;$!ba;s/\n/,/g' | perl -pe 's{,}{++$n % 10 ? $& : "\n"}ge' > fasce4.txt
##	cat paliHeader.csv fasce4.txt > fasce5.txt
	paliCol="paliColumn.csv"
	if test $i -lt 20160131; then
		paliCol="paliColumn1.csv"
	fi
	sed '/mv/d' < $paliCol | cat > paliColumnTemp.csv
	paliTmp="paliColumnTemp.csv"
	awk 'OFS="," {getline to_add < "'"$paliTmp"'"}{print "'"$i"'",to_add,$0}' fasce4.txt > fasce6.txt
	cat fasce6.txt >> paliViews.csv
	rm fasce*
done
cp paliViews.csv ../../log/paliViews$year.csv
rm paliViews.csv
echo "te se qe te ve be te ne"

##tr '\n' ',' < fasce2.txt | cat > fasce3.txt




