<?php
header("Content-Type: application/json");

$host = 'localhost';
$user = 'root';
$pass = '';
$db = 'festival_card';

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    echo json_encode(["error" => "Connection failed"]);
    exit();
}

$result = $conn->query("SELECT name FROM categories");
if (!$result) {
    echo json_encode(["error" => "Failed to fetch categories"]);
    exit();
}

$response = [];

while ($row = $result->fetch_assoc()) {
    $category = strtolower($row['name']);
    $table = $category . "_templates";

    $templateResult = $conn->query("SELECT image_path FROM `$table`");
    $templates = [];

    if ($templateResult) {
        while ($template = $templateResult->fetch_assoc()) {
            $templates[] = $template['image_path'];
        }
    }

    $response[] = [
        "category" => $row['name'],
        "templates" => $templates
    ];
}

echo json_encode($response);
$conn->close();
?>
