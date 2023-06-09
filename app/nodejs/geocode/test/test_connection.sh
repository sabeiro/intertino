#curl -X POST -H "Content-Type: application/json" -d '{"time_call":"2020-03-14 21:03:00","time_hospitalization":"2020-03-14 21:43:00","unit_type":"CT","success":"yes","lat_unit":45.554,"lng_unit":10.232,"lat_call":45.579,"lng_call":10.497}' http://localhost:/intertino/node/geocode/db.php
curl -d "@row_db.json" -X POST http://localhost:/intertino/node/geocode/db.php
