import os, sys, gzip, random, json, datetime, re
import requests
from bs4 import BeautifulSoup
import pandas as pd
from requests_html import HTMLSession
from selenium import webdriver
from selenium.webdriver.firefox.options import Options

def parse_table(url,n_tab=0,skip_row=0,render=False,isHead=False):
    """parse table reading html"""
    if render:
        session = HTMLSession()
        page = session.get(url)
        page.html.render()
        head = page.html.find('thead')
    else:
        page = requests.get(url)
    soup = BeautifulSoup(page.text, 'html.parser')
    table = soup.find_all('tbody')
    inve = table[n_tab]
    data = [] 
    rows = inve.find_all('tr')
    rows = rows[skip_row:]
    for row in rows:
        cols = row.find_all('td')
        cols = [ele.text.strip() for ele in cols]
        data.append([ele for ele in cols]) 
    if isHead:
        script = soup.findAll('script')
        head = soup.find_all('thead')
        head = head[0].find_all('th')
        head = [ele.text.strip() for ele in head]
        invD = pd.DataFrame(data,columns=head)
    else :
        invD = pd.DataFrame(data)
    return invD

def parse_tr(url,n_tab=0,skip_row=0,render=False,isHead=False):
    """parse table reading html"""
    page = requests.get(url)
    soup = BeautifulSoup(page.text, 'html.parser')
    table = soup.find_all('table')
    inve = table[n_tab]
    data = [] 
    rows = inve.find_all('tr')
    rows = rows[skip_row:]
    for row in rows:
        cols = row.find_all('td')
        cols = [ele.text.strip() for ele in cols]
        data.append([ele for ele in cols]) 
    head = rows[0].find_all('th')
    head = [ele.text.strip() for ele in head]
    invD = pd.DataFrame(data,columns=head)
    return invD

def parse_selenium(url):
    """seleniun headless mode"""
    options = Options()
    options.headless = True
    path = os.environ['HOME'] + '/bin/geckodriver'
    browser = webdriver.Firefox(options=options, executable_path=path)
    browser.get(url)
    head = browser.find_elements_by_xpath("//table/thead/tr")
    row = head[0].find_elements_by_xpath(".//tr")
    for h in head:
        print(h.find_elements_by_xpath("//tr"))
        rL = [td.text for td in row.find_all('td')]
        print(rL)
    
    for row in head[2].find_elements_by_xpath(".//tr"):
        rL = [td.text for td in row.find_elements_by_xpath(".//td")]
        rL = [td.text for td in row.find_all('td')]
        print(rL)
        
    rows = browser.find_elements_by_xpath("html/body/table/tbody/tr")
    print("Headless Firefox Initialized")
    browser.quit()

def selenium_graphics(url):
    """start selenium browsing"""
    path = os.environ['HOME'] + '/bin/geckodriver'
    browser = webdriver.Firefox(executable_path=path)
    browser.get(url)
    totals_rows = browser.find_elements_by_xpath("//table/tbody/tr")
    
    browser.quit()



    
