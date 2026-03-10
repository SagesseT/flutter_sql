<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$conn = new mysqli("localhost","root","","test_flutter");

if($conn->connect_error){
    die("connection failed");
}

$nom = $_POST['nom'];
$email = $_POST['email'];

$sql = "INSERT INTO utilisateurs(nom,email) VALUES('$nom','$email')";

if($conn->query($sql)){
    echo json_encode(["success"=>true]);
}else{
    echo json_encode(["success"=>false]);
}

?>