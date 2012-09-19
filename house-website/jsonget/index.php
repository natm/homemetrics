<?php


	$unique = "json";

	$val = apc_fetch($unique);
	if (empty($val)) {

		$url = "valstore.nuqe.net/json";
		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_HEADER, 0);
	        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		$val = curl_exec($ch);
	        curl_close($ch);

		apc_store($unique,$val,15);
	}

	header('Content-type: application/json');
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
