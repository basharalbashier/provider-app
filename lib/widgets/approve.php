<?php
ini_set('display_errors',1); 
error_reporting(E_ALL);
include '../database.php';


//$sSQL = 'SET CHARACTER SET utf8';
//mysqli_query($link, $sSQL) or die('Can\'t charset in DataBase');


$image = $_FILES['image']['name'];
$name = $_POST['name'];
$namee = $_POST['namee'];
$phone = $_POST['phone'];
$phonet = $_POST['phonet'];
$job = $_POST['job'];
$joba = $_POST['joba'];
$jobb = $_POST['jobb'];
$jobc = $_POST['jobc'];
$lid = $_POST['lid'];


//$imageid=$_FILES['idPic']['name'];

  $imagePath = "$phone";

$dooo=move_uploaded_file($_FILES['image']['tmp_name'],$imagePath);

$link->query("INSERT INTO `wo`(`name`,`namee`,`phone`,`phonet`,`job`,`joba`,`jobb`,`jobc`,`lid`,`image`)
VALUES
('".$name."','".$namee."','".$phone."','".$phonet."','".$job."','".$joba."','".$jobb."','".$jobc."','".$lid."','".$image."')");


if (mysqli_affected_rows($link)==1) {
	//echo json_encode(mysqli_insert_id($link));
	//$imagePathid = json_encode(mysqli_insert_id($link));

	//move_uploaded_file($_FILES['idPic']['tmp_name'],$imagePathid);

	echo json_encode(mysqli_error($dooo));

} else {
	echo json_encode(mysqli_error($link));
}
