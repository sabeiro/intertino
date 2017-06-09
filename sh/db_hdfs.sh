for i in *csv
do
#	hdfs dfs -mkdir /intertino/${i/csv/}
#    hdfs dfs -put $i /intertino/
    cat $i | ssh sabeiro@intertino "hadoop dfs -put - intertino/"
#    tar cf - . | ssh remote "(cd /destination && tar xvf -)"
done

curl -i "http://analisi.ad.mediamond.it:14000?op=homedir&amp;user.name=root"
curl -i "http://analisi.ad.mediamond.it:14000?/intertino/?op=list&amp;user.name=root"
curl -i "http://analisi.ad.mediamond.it:14000?/intertino/data.txt?op=create&amp;user.name=root"


curl -i "http://hoopbar:14000?/user/babu/hello.txt&amp;user.name=babu"

curl -i -X POST "http://hoopbar:14000/user/babu/data.txt?op=create" --data-binary @mydata.txt --header "content-type: application/octet-stream"
curl -i "http://hoopbar:14000?/user/babu?op=list&amp;user.name=babu"


