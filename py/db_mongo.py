from pymongo import
MongoClient
client = MongoClient('localhost', 27017)
db = client.test_database
access_token_store = AuthCodeStore(collection=db["auth_codes"])
access_token_store = AccessTokenStore(collection=db["access_tokens"])
