import os, sys, gzip, random, json, datetime, re
import pandas as pd

dL = os.listdir(os.environ['LAV_DIR']+'/src/')
sys.path = list(set(sys.path + [os.environ['LAV_DIR']+'/src/'+x for x in dL]))
baseDir = os.environ['LAV_DIR']
import intertino.parser as pars

import importlib
importlib.reload(pars)

def conv_string(x):
    try: return float(x)
    except: return 0.

if False:
    """country code"""
    url = "https://www.countrycode.org/"
    couD = pars.parse_table(url,n_tab=0,render=True,isHead=True)
    couD.loc[:,"iso"] = couD['ISO CODES'].apply(lambda x: x[:2])
    couD.loc[:,"POPULATION"] = couD['POPULATION'].apply(lambda x: int(re.sub(",","",x)))
    couD.loc[:,"GDP"] = couD['GDP $USD'].apply(lambda x: x.split(" ")[0])
    couD.loc[:,"GDP_fact"] = 0.
    couD.loc[[bool(re.search("Trillion",x)) for x in couD['GDP $USD']],"GDP_fact"] = 1e12
    couD.loc[[bool(re.search("Billion",x)) for x in couD['GDP $USD']],"GDP_fact"] = 1e9
    couD.loc[[bool(re.search("Million",x)) for x in couD['GDP $USD']],"GDP_fact"] = 1e6
    couD.loc[[x == "" for x in couD['GDP']],"GDP"] = "0"
    couD.loc[:,"GDP"] = couD[['GDP','GDP_fact']].apply(lambda x: conv_string(x[0]) * x[1],axis=1)
    couD.drop(columns={"GDP_fact",'GDP $USD'},inplace=True)
    couD.loc[:,"AREA KM2"] = couD['AREA KM2'].apply(lambda x: conv_string(re.sub(",","",x)))
    couD.loc[:,"dens"] = couD['POPULATION']/couD['AREA KM2']
    couD.loc[:,"gdp_capita"] = couD['GDP']/couD['POPULATION']

    url = "https://developers.google.com/public-data/docs/canonical/countries_csv"
    cooD = pars.parse_tr(url,n_tab=0,render=True,isHead=True)
    couD = couD.merge(cooD,left_on="iso",right_on="country",how="left")
    couD.to_csv(baseDir + "geo/demo/country_demo.csv",index=False)

if False:
    """world population"""
    url = "https://www.worldometers.info/world-population/population-by-country/"
    invD = pars.parse_table(url,n_tab=0)
    invD.to_csv(baseDir + "geo/demo/pop_country.csv",index=False)

if False:
    """world population"""
    url = "https://www.worldometers.info/world-population/world-population-by-year/"
    invD = pars.parse_table(url,n_tab=0)
    invD.to_csv(baseDir + "geo/demo/pop_year.csv",index=False)

if False:
    """population density"""
    url = "https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population_density"
    invD = pars.parse_table(url,n_tab=0,render=True,isHead=False)
    invD.to_csv(baseDir + "geo/demo/pop_dens.csv",index=False)
    
    
