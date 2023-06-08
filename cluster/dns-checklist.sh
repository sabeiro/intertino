#!/usr/bin/env bash

# For each record, check if it's been set.
# If it has, mark it as checked
# If not, mark it as not checked
# If it has a wrong value, mark it as wrong.

# Dependencies: dig, for DNS queries

DOMAIN="$1"
MAIL_IP="${2:-"95.217.2.28"}"
RESOLVER="${RESOLVER:-"8.8.8.8"}"
DKIM_SELECTOR="default"

declare SYMBOLS=( "Y" " " "E")
Y=0
N=1
E=2

function dig_wrap() {
  local r

  r=$(dig @${RESOLVER} +short "$@" | grep -v '^;;')

  if [ $? -ne 0 ]; then
    return 1
  fi

  if [ -z "$r" ]; then
    return 1
  fi

  echo "$r"

  return 0
}

function check_record_MX() {
  local content
  local expected="mail.${DOMAIN}."

  content=$(dig_wrap "$DOMAIN" MX) || {
    echo "@ 10800 IN MX 10 $expected"
    return $N
  }

  # all good
  if egrep -q "^[0-9]+ mail\.${DOMAIN}\.$" <<< "$content"; then
    return $Y
  fi

  # MX configured, but not ours!
  echo "Key:      @"
  echo "Expected: $expected"
  echo "Got:      $content"

  return $E
}

function check_record_DMARC() {
  local content
  local expected

  expected="v=DMARC1; p=none; rua=mailto:postmaster@$DOMAIN;"

  content=$(dig_wrap "_dmarc.$DOMAIN" TXT) || {
    echo "_dmarc 10800 IN TXT \"$expected\""
    return $N
  }

  # all good
  if egrep -q "^\"$expected\"$" <<< "$content"; then
    return $Y
  fi

  # DMARC configured, but not ours!
  echo "Key:      _dmarc.$DOMAIN"
  echo "Expected: \"$expected\""
  echo "Got:      $content"

  return $E
}

function check_record_A() {
  local content

  content=$(dig_wrap "mail.$DOMAIN" A) || {
    echo "@ 10800 IN A ${MAIL_IP}"
    return $N
  }

  # all good
  if egrep "^${MAIL_IP}$" <<< "$content"; then
    return $Y
  fi

  # wrong A record
  echo "Key:      @"
  echo "Expected: $MAIL_IP"
  echo "Got:      $content"

  return $E
}

function check_record_DKIM() {
  local key_file="$(dirname $(realpath "$0"))/origconf/etc/opendkim/keys/$DOMAIN/$DKIM_SELECTOR.txt"

  [ -e "$key_file" ] || {
    echo "error: Missing key file";
    return $E;
  }

  local expected=$(sed 's|^\([^"]\+\)"\([^"]\+\)"\(.*\)$|\2|g' < "$key_file" | tr -d '\n')

  local content

  content=$(dig_wrap "$DKIM_SELECTOR._domainkey.$DOMAIN" TXT | sed 's|" "||g;s|"||g' | tr -d '\n') || {
    echo "$DKIM_SELECTOR._domainkey 10800 IN TXT \"$expected\""
    return $N
  }

  if [ -z "$content" ]; then
    echo "$DKIM_SELECTOR._domainkey 10800 IN TXT \"$expected\""
    return $N
  fi

  if [ "$expected" != "$content" ]; then
    echo "Key:      $DKIM_SELECTOR._domainkey"
    echo "Expected: \"$expected\""
    echo "Got:      $content"

    return $E
  fi

  echo "$expected"

  return $Y
}

function check_record_SPF() {
  local content
  local matched
  local expected="v=spf1 include:_spf.lightmetermail.io ~all"

  content=$(dig_wrap "$DOMAIN" TXT | grep '"v=spf1') || {
    echo "$DOMAIN 10800 IN TXT \"$expected\""
    return $N
  }

  matched=$(egrep '^"v=spf1.* include:_spf.lightmetermail.io .*' <<< "$content")

  if [ -z "$matched" ]; then
    echo "Expected: \"$expected\""
    echo "Got:      $content"

    return $E
  fi

  return $Y
}

function check_record_Google() {
  local filepath="$(dirname $(realpath "$0"))/../ns.lightmetermail.io/gen_nsd_conf.py"
  local expected=$(grep "$DOMAIN" -m1 < $filepath | sed 's|.*"\(.*\)",$|\1|g')

  if [ -z "$expected" ]; then
    echo "Key not registered"
    return $E
  fi

  local content

  content=$(dig_wrap "$DOMAIN" TXT | grep '^"google-site-verification=') || {
    echo "@ 10800 IN TXT \"$expected\""
    return $N
  }

  if [ -z "$content" ]; then
    echo "@ 10800 IN TXT \"$expected\""
    return $N
  fi

  if [ "\"$expected\"" != "$content" ]; then
    echo "Key:      @"
    echo "Expected: \"$expected\""
    echo "Got:      $content"

    return $E
  fi

  echo "$expected"

  return $Y
}

ALL_CHECKS=(A MX DMARC DKIM SPF Google)

echo -e "Checklist for DNS records:\n"

for record in ${ALL_CHECKS[@]}; do
  response=$("check_record_$record")
  return_code="$?"
  code=${SYMBOLS[$return_code]}

  echo -n "[ $code ] -- $record record"

  if [ "$return_code" -ne "$Y" ]; then
    echo ":"
    echo "$response"
  fi

  echo
done

echo "TODO: check DuoCircle dkim key?"
