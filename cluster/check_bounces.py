
import os, sys, csv, re

# apt install python3-dnspython python3-publicsuffix2
import dns.resolver
from publicsuffix2 import get_public_suffix


usage = "Usage: python3 check_bounces.py bounces_file.csv\n"

if len(sys.argv) < 2:
	print(usage)
	sys.exit(1)

f = sys.argv[1]

rows = list()

try:
	with open(sys.argv[1], "r") as f:
		reader = csv.reader(f, delimiter=',')
		for row in reader:
			rows.append(row)
except IOError:
	print("First argument is not a file")
	print(usage)
	sys.exit(1)


header = rows[0]
c = {}

# Queue	MessageID	NumberOfAttempts	TimeMin	TimeMax	Status	DSN	Expired	MailFrom	MailTo	Relays	RawLogMsgs
i = 0
for h in header:
	c[h] = i
	i += 1


blockedUsers = {}
spammedMXs = {}

def nothingToDo(rule, row):
	print("# {Tag} {MailTo}".format(
		Tag = f"[lm:{rule['name']}]",
		MailTo = row[c["MailTo"]],
		Date = row[c["TimeMax"]],
		RawLog = row[c["RawLogMsgs"]],
	))

def blockUser(rule, row):
	mailto = row[c["MailTo"]]
	blockedUsers[mailto] = f"{mailto}    error:5.1.1 Mailbox doesn't exist. Lightmeter blocked sending.    # [lm:not-a-mailbox] {row[c['TimeMax']]} {row[c['RawLogMsgs']]}\n"

def rerouteSpammedMX(rule, row):
	topmx = get_mx_topdomain(row[c["MailTo"]])
	spammedMXs[topmx] = f"{topmx}    relay:[outbound.mailhop.org]:587  # [lm:spammed] {row[c['TimeMax']]} {row[c['RawLogMsgs']]}\n"

def get_mx_topdomain(email_addr):
	domain = email_addr.split("@")[1]
	preferred_mx = None
	for mx in dns.resolver.resolve(domain, 'MX'):
		if preferred_mx == None or mx.preference < preferred_mx.preference:
			preferred_mx = mx
	
	if not preferred_mx:
		print(f"Can't find MX for {email_addr}")
		sys.exit(1)
	
	return get_public_suffix(str(preferred_mx.exchange))


rules = [
	{
		# TODO: check this one
		"name": "internal",
		"re": re.compile(r""".*
			relay=lightmetermail.io\[private/dovecot-lmtp |
			@lightmeter.io.*relay=none.*Host.or.domain.name.not.found |
			mailbox-does-not-exist.lightmetermail.io
			""", re.VERBOSE),
		"action": nothingToDo
	},
	{
		"name": "not-a-mailbox",
		"re": re.compile(r""".*(
			DisabledUser |    # google URL
			NoSuchUser |      # google URL
			User.Unknown |
			permanent.failure.for.one.or.more.recipients |
			550.Invalid.Recipient |
			550.5.1.1.User.Unknown |
			550.5.7.1.Invalid.recipient.address
			)""", re.IGNORECASE | re.VERBOSE),
		"action": blockUser
	},
	{
		"name": "duocircle-spam",
		"re": re.compile(r'.*classified as spam.*false positive.*support ticket.*duocircle\.com'),
		"action": nothingToDo
	},
	{
		"name": "spammed",
		"re": re.compile(r""".*(
			mimecast.*Email.rejected.due.to.security.policies |
			outlook.*5.4.1.Recipient.address.rejected:.Access.denied |
			iphmx.*Your.access.to.this.mail.system.has.been.rejected.due.to.poor.reputation.of.a.domain |
			secureserver.*rejected.due.to.content.judged.to.be.spam.by.the.internet.community.IB212 |
			554.rejected.due.to.spam.URL.in.content
			)""", re.VERBOSE),
		"action": rerouteSpammedMX
	},
	{
		"name": "glockapps",
		"re": re.compile(r'.*glocktest.*530 5.7.1 Authentication required'),
		"action": nothingToDo
	},
	{
		"name": "dns-issue",
		"re": re.compile(r""".*(
			type=A:.Host.not.found |
			type=A:.Host.found.but.no.data.record.of.requested.type
			)""", re.VERBOSE),
		"action": nothingToDo
	},
	{
		"name": "relay-issue",
		"re": re.compile(r""".*(
			not.permitted.to.relay.through.this.server |
			5.7.1.Relaying.denied |
			550.relay.not.permitted |
			Could.not.obtain.destination.server
			)""", re.VERBOSE),
		"action": nothingToDo
	},
]

for row in rows[1:]:
	if row[c["Status"]] != "bounced":
		continue
	
	rawlog = row[c["RawLogMsgs"]]
	if not rawlog:
		continue
	
	matched = False
	for rule in rules:
		if rule["re"].match(rawlog):
			matched = True
			rule["action"](rule,row)
			continue
	
	if not matched:
		print(f"# [lm:unknown] {row[c['TimeMax']]} {rawlog}")


def writeRulesTo(rules, filename):
	if not os.path.exists(filename):
		print(f"File should exist: '{filename}'")
		sys.exit(1)

	with open(filename, "a") as f:
		for k, line in rules.items():
			f.write(line)

writeRulesTo(blockedUsers, "origconf/etc/postfix/recipient_transport_map_base")
writeRulesTo(spammedMXs, "recipient_routing")

