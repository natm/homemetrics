<?php

	$type = checkvar("type");
	$key = checkvar("key");

	$unique = $type . "_" . $key;

	$val = apc_fetch($unique);
	if (empty($val)) {

		$url = "valstore.nuqe.net/get?key=" . $key . "&type=" . $type;
		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_HEADER, 0);
	        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		$val = curl_exec($ch);
	        curl_close($ch);

		apc_store($unique,$val,20);
	}

	echo $val;

	function checkvar($varname) {
		if (!isset($_REQUEST[$varname])) {
			exit();
		}
		if (empty($_REQUEST[$varname])) {
			exit();
		}
		if (!ctype_alnum($_REQUEST[$varname])) {
			exit();
		}
		return $_REQUEST[$varname];
	}
?>
