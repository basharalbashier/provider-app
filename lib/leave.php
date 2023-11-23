<?php 

	
include '../database.php';


 $sSQL= 'SET CHARACTER SET utf8';
 mysqli_query($link,$sSQL) or die ('Can\'t charset in DataBase');

 $id=$_POST['userphone'];

	$link->query("UPDATE `wo` SET  `orderw`= 0 WHERE `inorder`= 0 ");
if($link){

    echo json_encode(1);
}

?>