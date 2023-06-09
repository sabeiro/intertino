<?php
error_reporting(E_ERROR | E_WARNING | E_PARSE);
error_reporting(E_ALL);

echo "qui\n";

$url = "http://dauvi.org:8069";
$db = "quaefacta";
$username = "admin";
$password = "odooSuxo0308:.";
echo "qui\n";

require_once('ripcord.php');

$info = ripcord::client('https://demo.odoo.com/start')->start();
list($url, $db, $username, $password) = array($info['host'], $info['database'], $info['user'], $info['password']);

$common = ripcord::client("$url/xmlrpc/2/common");
$common->version();

echo "qui";
$uid = $common->authenticate($db, $username, $password, array());

echo "qui";
$models = ripcord::client("$url/xmlrpc/2/object");
$models->execute_kw($db, $uid, $password,'res.partner', 'check_access_rights',array('read'), array('raise_exception' => false));
$models->execute_kw($db, $uid, $password,'res.partner', 'search', array(array(array('is_company', '=', true),array('customer', '=', true))));


?>
