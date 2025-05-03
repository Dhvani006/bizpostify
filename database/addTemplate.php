<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$host = 'localhost';
$user = 'root';
$pass = '';
$db = 'festival_card';

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("DB Connection Failed: " . $conn->connect_error);
}

if (!isset($_FILES['templateImage']) || !isset($_POST['category'])) {
    die("Missing file or category.");
}

$category = strtolower(trim($_POST['category']));
$table = $category . '_templates';

if (!is_dir("Template_images")) {
    mkdir("Template_images");
}

$file = $_FILES['templateImage'];
$filename = basename($file['name']);
$targetPath = "Template_images/" . $filename;

if (move_uploaded_file($file['tmp_name'], $targetPath)) {
    $sqlInsert = "INSERT INTO `$table` (image_path) VALUES ('$targetPath')";
    if ($conn->query($sqlInsert)) {
        echo "Template uploaded and saved in DB.";
    } else {
        echo "DB Insert failed.";
    }
} else {
    echo "File upload failed.";
}

$conn->close();
?>
