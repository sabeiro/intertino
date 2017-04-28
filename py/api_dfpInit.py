import json
import os
import argparse
import sys
from oauth2client import client
from googleads import dfp
from googleads import oauth2

##os.chdir('/home/sabeiro/lav/media')
key_file = os.environ['HOME'] + '/lav/media/credenza/dfp-intertino-861da83250a9.json'
key_file2 = os.environ['HOME'] + '/lav/media/credenza/dfp-intertino.json'

cred = []
with open(key_file) as f:
    cred = json.load(f)
cred2 = []
with open(key_file2) as f:
    cred2 = json.load(f)
DEFAULT_CLIENT_ID = cred2['client_id']
DEFAULT_CLIENT_SECRET = cred2['client_secret']
##cred2['refresh_token']

flow = client.OAuth2WebServerFlow(client_id=cred2['client_id'],client_secret=cred2['client_secret'],scope=oauth2.GetAPIScope('adwords'),user_agent='Test',redirect_uri=cred2['redirect_uri'])
auth_uri = flow.step1_get_authorize_url()

# from oauth2client.client import flow_from_clientsecrets
# flow = flow_from_clientsecrets('credenza/dfp-intertino.json',scope='https://www.googleapis.com/auth/calendar',redirect_uri='http://analisi.ad.mediamond.it')


# The DFP API OAuth2 scope.
SCOPE = u'https://www.googleapis.com/auth/dfp'

parser = argparse.ArgumentParser(description='Generates a refresh token with '
                                 'the provided credentials.')
parser.add_argument('--client_id', default=DEFAULT_CLIENT_ID,
                    help='Client Id retrieved from the Developer\'s Console.')
parser.add_argument('--client_secret', default=DEFAULT_CLIENT_SECRET,
                    help='Client Secret retrieved from the Developer\'s '
                    'Console.')
parser.add_argument('--additional_scopes', default=None,
                    help='Additional scopes to apply when generating the '
                    'refresh token. Each scope should be separated by a comma.')


def main(client_id, client_secret, scopes):
  """Retrieve and display the access and refresh token."""
  flow = client.OAuth2WebServerFlow(
      client_id=client_id,
      client_secret=client_secret,
      scope=scopes,
      user_agent='Ads Python Client Library',
      redirect_uri=cred2['redirect_uri'])
#      redirect_uri='urn:ietf:wg:oauth:2.0:oob')

  authorize_url = flow.step1_get_authorize_url()

  print ('Log into the Google Account you use to access your DFP account'
         'and go to the following URL: \n%s\n' % (authorize_url))
  print 'After approving the token enter the verification code (if specified).'
  code = raw_input('Code: ').strip()

  try:
    credential = flow.step2_exchange(code)
  except client.FlowExchangeError, e:
    print 'Authentication has failed: %s' % e
    sys.exit(1)
  else:
    print ('OAuth2 authorization successful!\n\n'
           'Your access token is:\n %s\n\nYour refresh token is:\n %s'
           % (credential.access_token, credential.refresh_token))


if __name__ == '__main__':
  args = parser.parse_args()
  configured_scopes = [SCOPE]
  if not (any([args.client_id, DEFAULT_CLIENT_ID]) and
          any([args.client_secret, DEFAULT_CLIENT_SECRET])):
    raise AttributeError('No client_id or client_secret specified.')
  if args.additional_scopes:
    configured_scopes.extend(args.additional_scopes.replace(' ', '').split(','))
  main(args.client_id, args.client_secret, configured_scopes)


# import httplib2
# from httplib2 import Http
# import sys
# import numpy as np
# import pandas as pd
# import datetime
# import ast
# import csv
# import argparse
# ##import dfp_config
# from googleads import dfp, oauth2
# from googleads.oauth2 import oauth2client
# from suds.sudsobject import asdict

# import ConfigParser
# config = ConfigParser.ConfigParser()
# config.read('dfp_param.py')
# print config.sections()
#print config.get('Order','columns')


# import oauth2client
# from oauth2client import client


# # oauth2_client = oauth2.GoogleServiceAccountClient(oauth2.GetAPIScope('dfp'),cred2['service_account_email'], key_file)
# # dfp_client = dfp.DfpClient(oauth2_client, application_name)
# oauth2_client = oauth2.GoogleServiceAccountClient(oauth2.GetAPIScope('dfp'),str(cred2['service_account_email']),key_file)
# oauth2_client = oauth2.GoogleRefreshTokenClient(cred2['client_id'],cred2['client_secret'],cred2['refresh_token'])
# dfp_client = dfp.DfpClient(oauth2_client,application_name)
# # Initialize the GoogleRefreshTokenClient using the credentials you received
# # in the earlier steps.
# oauth2_client = oauth2.GoogleServiceAccountClient(oauth2.GetAPIScope('dfp'),cred['client_email'],'intertino-a80f4d829b76.json')

# # Initialize the DFP client.
# dfp_client = dfp.DfpClient(oauth2_client,application_name)

# # credentials = ServiceAccountCredentials.from_json_keyfile_name(key_file,cred2['scopes'])

# flow = client.flow_from_clientsecrets(key_file,scope='https://www.googleapis.com/auth/drive.metadata.readonly',redirect_uri='http://www.example.com/oauth2callback')

# from oauth2client.client import flow_from_clientsecrets
# flow = flow_from_clientsecrets(key_file,scope='https://www.googleapis.com/auth/calendar',redirect_uri='http://example.com/auth_return')

# # credentials = AppAssertionCredentials('https://www.googleapis.com/auth/sqlservice.admin')
# # from oauth2client.contrib.gce import AppAssertionCredentials
# # credentials = AppAssertionCredentials('https://www.googleapis.com/auth/sqlservice.admin')

# scopes = ['https://www.googleapis.com/auth/sqlservice.admin']
# credentials = ServiceAccountCredentials.from_json_keyfile_name('intertino-a80f4d829b76.json', scopes=scopes)

# #https://www.googleapis.com/auth/dfareporting

# #https://www.googleapis.com/dfareporting/v2.7/userprofiles/4758/reports/reportId








