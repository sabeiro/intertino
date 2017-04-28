from cassandra.cluster import Cluster
import json
key_file = os.environ['HOME'] + '/lav/media/credenza/intertino.json'
cred = []
with open(key_file) as f:
    cred = json.load(f)
cred = cred['cassandra']
cluster = Cluster([cred['host']])
session = cluster.connect(cred['keyspace'])
#session.set_keyspace('users')
rows = session.execute('SELECT name, age, email FROM users')
for user_row in rows:
    print user_row.name, user_row.age, user_row.email

session.execute("""insert into users (lastname, age, city, email, firstname) values ('Jones', 35, 'Austin', 'bob@example.com', 'Bob')""")
result = session.execute("select * from users where lastname='Jones' ")[0]
print result.firstname, result.age

