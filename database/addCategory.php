<?php
$host = 'localhost';
$user = 'root';
$pass = '';
$db = 'festival_card';

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Validate category
if (!isset($_POST['category']) || empty(trim($_POST['category']))) {
    die("No category provided.");
}

$originalCategory = trim($_POST['category']);
$category = strtolower(str_replace(' ', '_', $originalCategory));
$table = $category . "_templates";

// Create template table
$sqlCreate = "CREATE TABLE IF NOT EXISTS `$table` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_path VARCHAR(255) NOT NULL
)";
if (!$conn->query($sqlCreate)) {
    die("Error creating template table: " . $conn->error);
}

// Insert into categories table
$sqlInsert = "INSERT INTO categories (name) VALUES (?)";
$stmt = $conn->prepare($sqlInsert);
$stmt->bind_param("s", $originalCategory);

if ($stmt->execute()) {
    echo "Category '$originalCategory' added successfully.";
} else {
    echo "Category insertion failed or already exists.";
}

$stmt->close();
$conn->close();
?>
