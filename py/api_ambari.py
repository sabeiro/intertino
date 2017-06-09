curl -u admin:'ambariKl3zmer:.' -H "X-Requested-By: ambari" -X GET  http://analisi.ad.mediamond.it:8080/api/v1/clusters/CLUSTER_NAME?fields=Clusters/desired_configs

curl --user admin:admin -i -X PUT -d '{"RequestInfo": {"context": "Stop HDFS"}, "ServiceInfo": {"state": "INSTALLED"}}' http://AMBARI_SERVER_HOST:8080/api/v1/clusters/CLUSTER_NAME/services/HDFS
