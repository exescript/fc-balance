#!/bin/bash

FC_IP='foodmobileapi.smartcard.ru'
FC_PORT='443'

LOGIN_REQ_FILE='login_req.txt'
LOGIN_REQ=
LOGIN_RES=
LOGIN_JSON=
LOGIN_ID=

INFO_REQ_FILE='getinfo_req.txt'
INFO_REQ=
INFO_RES=
INFO_JSON=

FOODCARD_BALANCE=
FOODCARD_LIMIT=

function login {
	LOGIN_REQ=`cat "$LOGIN_REQ_FILE"; echo; echo "password=$2"'&'"username=$1"`
	LOGIN_RES=`echo -e "$LOGIN_REQ" | timeout 2 openssl s_client -quiet -connect "$FC_IP":"$FC_PORT" 2>/dev/null`
	LOGIN_JSON=`echo -e "$LOGIN_RES" | tail -n 1 | jq '.'`
	LOGIN_ID=`echo -e "$LOGIN_RES" | grep -i Cookie | tr '=;:' '\t' | awk '{print $3}'`
}

function get_info {
	INFO_REQ=`cat "$INFO_REQ_FILE" | sed "s/Cookie:/Cookie: JSESSIONID=$LOGIN_ID/"`
	INFO_RES=`(echo -e "$INFO_REQ"; echo) |  timeout 2 openssl s_client -quiet -connect "$FC_IP":"$FC_PORT" 2>/dev/null`
	INFO_JSON=`echo -e "$INFO_RES" | tail -n 3 | head -n 1 | jq -r '.'`
}

function get_foodcard_balance {
	FOODCARD_BALANCE=`echo -e "$INFO_RES" | tail -n 3 | head -n 1 | jq -r '.[].onlLimOnService[].balance'`
	FOODCARD_LIMIT=`echo -e "$INFO_RES" | tail -n 3 | head -n 1 | jq -r '.[].onlLimOnService[].limit'`
}

function print_foodcard_balance
{
	echo "----------------------------"
	echo '( x ) FoodCard balance: ' "[ $FOODCARD_BALANCE" '\' "$FOODCARD_LIMIT ]" 
	echo "============================"
	echo
}

function login_print 
{
	echo "============================"
	echo "[ *****  Login info  ******] "
	echo "----------------------------"
	echo "[ x ] login HTTP request:"
	echo "___________________________"
	echo "$LOGIN_REQ"

	echo "---------------------------"
	echo "[ x ] login HTTP response:"
	echo "___________________________"
	echo "$LOGIN_RES"
	echo 

	echo "---------------------------"
	echo "[ x ] login response JSON:"
	echo "___________________________"
	echo -e "$LOGIN_RES" | tail -n 1 | jq '.'
	echo

	echo "---------------------------"
	echo '[ x ] login session ID: '" $LOGIN_ID"
	echo "==========================="
	echo
}

function get_info_print 
{
	echo "============================"
	echo '[ ****** Card   info ****** ]'
	echo "----------------------------"
	echo "[ + ] card info HTTP request:"
	echo "___________________________"
	echo "$INFO_REQ"
	echo

	echo "---------------------------"
	echo "[ + ] card info HTTP response:"
	echo "___________________________"
	echo "$INFO_RES"
	echo

	echo "---------------------------"
	echo "[ + ] card info JSON:"
	echo "___________________________"
	echo -e "$INFO_RES" | tail -n 3 | head -n 1 | jq -r '.'
	echo
}

let argc="$#"

if [ $argc -ne "2" ];
then
	echo "Usage: $0 [card] [pass]"
	echo
	echo '<card> <pass>'
	echo '<card> : 10 digitss'
	echo '<pass> : 4 digits'
	exit
fi

# -----------------------------
login $1 $2

login_print
# -----------------------------
get_info
get_foodcard_balance

get_info_print
print_foodcard_balance
# -----------------------------
