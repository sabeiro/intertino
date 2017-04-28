import sys, urllib2
import openpyxl
import xlrd
import csv
from os import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
pd.set_option('max_columns', 50)
%matplotlib inline
from pandas.io import sql
import sqlite3

conn = sqlite3.connect('analisi.ad.mediamond.it')
query = "SELECT * FROM intertino WHERE make = 'FORD';"
##results = sql.read_sql(query, con=conn)
##results.head()


req = urllib2.Request(primeUrl)
response = urllib2.urlopen(req)
excel = response.read()
out_file = open("test.xls","w")
out_file.write(excel)
out_file.close()
data_xls = pd.read_excel('test.xls','FASCIA_PRIMETIME',index_col=None)
data_xls.head()
print data_xls[:3]


##url = 'https://raw.github.com/gjreda/best-sandwiches/master/data/best-sandwiches-geocode.tsv'
##from_url = pd.read_table(url, sep='\t')
##from_url.head(3)



data_xls.to_csv('your_csv.csv',encoding='utf-8')





def csv_from_excel(primeUrl):
    req = urllib2.Request(primeUrl)
    response = urllib2.urlopen(req)
    excel = response.read()
    out_file = open("test.xls","w")
    out_file.write(excel)
    out_file.close()
    workbook = xlrd.open_workbook("test.xls")
    all_worksheets = workbook.sheet_names()
    for worksheet_name in all_worksheets:
        worksheet = workbook.sheet_by_name(worksheet_name)
        your_csv_file = open(''.join([worksheet_name,'.csv']), 'wb')
        wr = csv.writer(your_csv_file, quoting=csv.QUOTE_ALL)

        for rownum in xrange(worksheet.nrows):
            wr.writerow([unicode(entry).encode("utf-8") for entry in worksheet.row_values(rownum)])
        your_csv_file.close()

        
        
if __name__ == "__main__":
    primeUrl = "http://medianet.mediaset.it/datimktg/sas/aud/REP_DBPRIMETIME/DBPT_1564.xls"
    csv_from_excel(primeUrl)



# http://medianet.mediaset.it/pls/portal/reports/rwservlet?repnetgraffmt&report=NGFRepMediePeriodo_xls.rdf&DESFORMAT=SPREADSHEET&DESTYPE=CACHE&DISTRIBUTE=NO&P_TipoP=&P_P=Periodo:%2003/12/2016-05/12/2016&P_DtDa=03/12/2016&P_DtA=05/12/2016&P_DtEDa=&P_DtEA=&P_F=Prime%20Time&P_OraDa=2030&P_OraA=2229&P_R1=&P_R2=&P_R3=&P_R4=&P_R5=&P_R6=0961&P_R7=0960&P_R8=0959&P_R9=0294&P_R10=&P_R11=0272&P_R12=&P_R13=&P_R14=&P_R15=&P_R16=&P_R17=&P_R18=&P_R19=&P_R20=&P_R21=&P_T1=40&P_T2=&P_T3=&P_T4=&P_T5=&P_V=A&P_NOTA= HTTP/1.1
# http://medianet.mediaset.it/pls/portal/marketing.documenti_const.filtriMediePeriodo
# http://medianet.mediaset.it/pls//portal/page/portal/Marketing/NavigazionePDF?_pageid=1013%2C404781&_dad=portal&_schema=PORTAL&GIORNO_MAX_TUAD0150=05%2F12%2F2016&GIORNO_MAX_TUAD0150_CON=11%2F01%2F2014&TIPO=2&CERCA=S&ALTEZZA=870&LARGHEZZA=1000&TIPO_REPORT=html&GiornoSel=04%2F12%2F2016&GiornoSelOld=04%2F12%2F2016&txtSettimana=&SettimanaSel=04%2F12%2F2016&Categoria=FSP&ReportDettaglio=FSP02&Target=1&PDFPATH=http%3A%2F%2Fmedianet.mediaset.it%2Fdatimktg%2Fsas%2FPDF_20161204%2Ffasce.pdf&FLAG_AUD=S 
# http://medianet.mediaset.it/pls/portal/nrpc/p?j=olark-611481021962740&&c=pollevents&q=5206.62740.61&i=ZhbNhgY7SWHyKyT83A39n3IfFOf20s2j&cb=hbl.client.callbacks.pollevents&after=1481021204175&next_poll_time=20000&v=veWWMVi7xQqWnk0Z3A39n5IfFO20U2fD&s=5175-497-10-3723&version=api-1.2.1&pretty=true&_rnd=0.3250290725387751 HTTP/1.1
# http://medianet.mediaset.it/portal/page/portal/Marketing/NavigazionePDF?_pageid=1013%2C404781&_dad=portal&_schema=PORTAL&GIORNO_MAX_TUAD0150=08%2F10%2F2016&GIORNO_MAX_TUAD0150_CON=11%2F01%2F2014&TIPO=2&CERCA=S&ALTEZZA=846&LARGHEZZA=1000&TIPO_REPORT=html&GiornoSel=21%2F09%2F2016&GiornoSelOld=21%2F09%2F2016&txtSettimana=&SettimanaSel=21%2F09%2F2016&Categoria=PAC&ReportDettaglio=PAC01&Palinsesto=8&Target=3&PDFPATH=http%3A%2F%2Fmedianet.mediaset.it%2Fdatimktg%2Fsas%2FPDF_20160921%2Fpalinsesti_multi.pdf&FLAG_AUD=S
# http://medianet.mediaset.it/portal/page/portal/Marketing/NavigazionePDF?GIORNO_MAX_TUAD0150=08%2F10%2F2016&GIORNO_MAX_TUAD0150_CON=11%2F01%2F2014&TIPO=2&CERCA=N&ALTEZZA=846&LARGHEZZA=1000&TIPO_REPORT=html&GiornoSel=21%2F09%2F2016&GiornoSelOld=21%2F09%2F2016&txtSettimana=&SettimanaSel=21%2F09%2F2016&Categoria=PAC&ReportDettaglio=PAC01&Palinsesto=8&Target=3&PDFPATH=http%3A%2F%2Fmedianet.mediaset.it%2Fdatimktg%2Fsas%2Faud%2FPDF_20160921%2Fpalinsesti_multi.pdf&FLAG_AUD=S



# http://medianet.mediaset.it/pls/portal/marketing.documenti_const.frameDbPrimeTime


# http://medianet.mediaset.it/datimktg/sas/aud/REP_DBPRIMETIME/DBPT_1564.xls


# http://medianet.mediaset.it/datimktg/sas/aud/PDF_20161008/palinsesti_multi.pdf






