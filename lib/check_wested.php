<?php
 include '../database.php';
 $sSQL= 'SET CHARACTER SET utf8';
 mysqli_query($link,$sSQL) or die ('Can\'t charset in DataBase');

 $id=$_POST['id'];
 $ida=$_POST['ida'];
 $idb=$_POST['idb'];
 $idc=$_POST['idc'];

	$query = $link->query("SELECT * FROM ra WHERE status =0 AND workerid=0 AND (typeid='".$id."' OR typeid='".$ida."' OR typeid ='".$idb."' OR typeid='".$idc."')");
	$result = array();

	while ($rowData = $query->fetch_assoc()) {
		$result[] = $rowData;
	}


	echo json_encode($result);


?>



