CREATE TABLE area (
  id INT NOT NULL AUTO_INCREMENT,
  Airport VARCHAR(255) ,
  AirpName VARCHAR(255) ,
  City VARCHAR(255) ,
  CityName VARCHAR(255) ,
  InactiveIndicator VARCHAR(255) ,
  LocationType VARCHAR(255) ,
  LocationSubtype VARCHAR(255) ,
  State VARCHAR(255) ,
  StateNam VARCHAR(255) ,
  Country VARCHAR(255) ,
  CountryN VARCHAR(255) ,
  SubCountry VARCHAR(255) ,
  GmtVar INT ,
  HamOdare VARCHAR(255) ,
  HamOdarN VARCHAR(255) ,
  HamKont VARCHAR(255) ,
  HamKontN VARCHAR(255) ,
  IataGVG VARCHAR(255) ,
  IataGVGN VARCHAR(255) ,
  CityGrp VARCHAR(255) ,
  CityGrpN VARCHAR(255) ,
  Bundle VARCHAR(255) ,
  BundName VARCHAR(255) ,
  StraBund VARCHAR(255) ,
  StrBunNm VARCHAR(255) ,
  TimeZone INT ,
  Longitude VARCHAR(255),
  Latitude VARCHAR(255),
  x VARCHAR(255) ,
  y VARCHAR(255) ,
  Ec_Flag VARCHAR(255) ,
  McbFlg VARCHAR(255) ,
  GX VARCHAR(255) ,
  GP VARCHAR(255) ,
  GP_FV VARCHAR(255) ,
  SubArNm VARCHAR(255) ,
  SubArCd VARCHAR(255) ,
  Capital VARCHAR(255) ,
  CapCity VARCHAR(255) ,
  PRIMARY KEY (id)
);

CREATE TABLE 'channel1' (id INT);
ALTER TABLE channel1 ADD COLUMN ch_cd VARCHAR(256);
ALTER TABLE channel1 ADD COLUMN ch_nm VARCHAR(256);



CREATE TABLE class (
  id INT NOT NULL AUTO_INCREMENT,
  cls_cd VARCHAR(255) ,
  comp_cd VARCHAR(255) ,
  nest_comp_num VARCHAR(255) ,
  nest_cls_num VARCHAR(255) ,
  rev_ind VARCHAR(255) ,
  co_upd_tms VARCHAR(255) ,
  PRIMARY KEY (id)
);

LOAD DATA INFILE "class.csv" INTO TABLE book_class COLUMNS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '' ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;



LOAD DATA INFILE "channel.csv" INTO TABLE CSVImport COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

load data local infile 'area.csv' into table area fields terminated by ',' enclosed by '"' lines terminated by '\n' (Airport,AirpName,City,CityName,InactiveIndicator,LocationType,LocationSubtype,State,StateNam,Country,CountryN,SubCountry,GmtVar,HamOdare,HamOdarN,HamKont,HamKontN,IataGVG,IataGVGN,CityGrp,CityGrpN,Bundle,BundName,StraBund,StrBunNm,TimeZone,Longitude,Latitude,x,y,Ec_Flag,McbFlg,GX,GP,GP_FV,SubArNm,SubArCd,Capital,CapCity
);


mysqlimport --ignore-lines=1 --fields-terminated-by=, --local -u kotoba -p lufthansa channel1.csv

