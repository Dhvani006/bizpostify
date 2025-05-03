<?php

$con = mysqli_connect("localhost", "root", "", "festival_card");

if (!$con) {
    die("Connection failed: " . mysqli_connect_error());
}

$query = "SELECT `id`, `img` FROM `frame`";
$exe = mysqli_query($con, $query);

$result = array();

while ($row = mysqli_fetch_assoc($exe)) {
    $result[] = $row;
}

echo json_encode($result);

?>
