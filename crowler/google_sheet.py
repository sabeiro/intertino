import os, sys, gzip, random, json, datetime, re
import requests
from bs4 import BeautifulSoup
import pandas as pd

dL = os.listdir(os.environ['LAV_DIR']+'/src/')
sys.path = list(set(sys.path + [os.environ['LAV_DIR']+'/src/'+x for x in dL]))
baseDir = os.environ['LAV_DIR']
url = json.load(open(baseDir + "entr/credenza/credenza.json"))
page = requests.get(url['investor'])
soup = BeautifulSoup(page.text, 'html.parser')
table = soup.find_all('tbody')
inve = table[1]

data = [] 
rows = inve.find_all('tr')
rows = rows[4:]
for row in rows:
    cols = row.find_all('td')
    cols = [ele.text.strip() for ele in cols]
    data.append([ele for ele in cols]) 

invD = pd.DataFrame(data)
invD.to_csv(baseDir + "entr/inv_list.csv",index=False)

