<?php
	$firstName = $_POST["firstName"];
	$lastName = $_POST["lastName"];
	$longitude = $_POST["longitude"];
	$latitude = $_POST["latitude"];

	$target_dir = "testing/photoUploads/" . $firstName . $lastName;
	if(!file_exists($target_dir))
	{
		mkdir($target_dir, 0777, true);
	}

	$target_dir = $target_dir . "/" . basename($_FILES["file"]["name"]);

	if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_dir)) 
	{
		echo json_encode([
		"Message" => "The file ". basename( $_FILES["file"]["name"]). " has been uploaded.",
		"Status" => "OK",
		"userId" => $_REQUEST["userId"]
	]);

	} else {

		echo json_encode([
		"Message" => "Sorry, there was an error uploading your file.",
		"Status" => "Error",
		"userId" => $_REQUEST["userId"]
		]);

	}

	//Store filepath into database with location/user-profile
	
?>
