import imaplib
import poplib
import re
import email
import email.header
import sys
import string
import os
import json
import datetime
from openpyxl import Workbook, load_workbook
import pandas as pd
import numpy as np

def parse_file1(filename):
    open("/tmp/"+filename,'wb').write(part.get_payload(decode=True))
    wb = load_workbook("/tmp/"+filename,data_only=True)
    ws = wb.active
    ##ws = wb['inventoryWeek']
    M = np.array([[x.value for x in y] for y in ws.rows])
    df = pd.DataFrame(M[1:],columns=M[0])

repL = ["adform","dotand","virgi"]
punctC = string.punctuation
key_file = os.environ['LAV_DIR'] + '/credenza/outlook.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)

##mailC = imaplib.IMAP4_SSL(cred['hostname'])
# mailC = imaplib.IMAP4(cred['hostname'],993)
# mailC.login(cred['bot_mail'],cred['bot_pass'])
mailC = poplib.POP3(cred['address'])
##mailC = poplib.POP3_SSL(cred['address'])
mailC.user(cred['bot_user'])
mailC.pass_(cred['bot_pass'])
print mailC
print mail.stat()
print mail.list()
print ""


typ, data = mailC.list()
print data
mailC.select()
#typ, data = mailC.search(None, 'UnSeen')#,'ALL')
typ, data = mailC.search(None, 'ALL')
for num in data[0].split():
    typ, data = mailC.fetch(num,'(RFC822)')#"(BODY.PEEK[])")
    if typ != 'OK':
        print "ERROR getting message", num
        continue

    email_body = data[0][1]
    msg = email.message_from_string(email_body)
    if not any([msg['from'].find(x) > 0 for x in repL]):
        continue
    if msg.get_content_maintype() != 'multipart':
        continue
    for part in msg.walk():
        if part.get_content_maintype() == 'multipart':
            continue
        if part.get('Content-Disposition') is None:
            continue
        filename = part.get_filename()
        if filename.find(".xlsx"):
            parse_file1(filename)
            
    decode = email.header.decode_header(msg['Subject'])[0]
    subject = decode[0].decode('utf-8','ignore').encode('utf-8','ignore')
    print 'Message %s: %s' % (num, subject)
    date_tuple = email.utils.parsedate_tz(msg['Date'])
    if date_tuple:
        local_date = datetime.datetime.fromtimestamp(email.utils.mktime_tz(date_tuple))

mailC.close()
mailC.logout()

