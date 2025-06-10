<?php
$host = "localhost";
$user = "root";
$pass = "";
$db = "festival_card";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Upload logo
$logo_name = '';
if (isset($_FILES['logo']) && $_FILES['logo']['error'] == 0) {
    $logo_name = basename($_FILES['logo']['name']);
    $target_path = "uploads/" . $logo_name;
    move_uploaded_file($_FILES['logo']['tmp_name'], $target_path);
} else {
    echo "No logo uploaded or upload error.";
    exit;
}

// Fetch form fields safely
$company_name = $_POST['company_name'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? ''; // Get password from POST
$facebook = $_POST['facebook'] ?? '';
$linkedin = $_POST['linkedin'] ?? '';
$twitter = $_POST['twitter'] ?? '';
$instagram = $_POST['instagram'] ?? '';
$mobile = $_POST['mobile'] ?? '';
$address = $_POST['address'] ?? '';

// Hash the password for security
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert data
$stmt = $conn->prepare("INSERT INTO users (company_name, email, password, facebook, linkedin, twitter, instagram, mobile, address, logo_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssssssss", $company_name, $email, $hashed_password, $facebook, $linkedin, $twitter, $instagram, $mobile, $address, $logo_name);

if ($stmt->execute()) {
    echo "Data inserted successfully";
} else {
    echo "Error: " . $stmt->error;
}

$conn->close();
?> 