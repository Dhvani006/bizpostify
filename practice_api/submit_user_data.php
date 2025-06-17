<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0);

$host = "localhost";
$user = "root";
$pass = "";
$db = "festival_card";

try {
    $conn = new mysqli($host, $user, $pass, $db);
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }

    // Upload logo
    $logo_name = '';
    if (isset($_FILES['logo']) && $_FILES['logo']['error'] == 0) {
        $logo_name = time() . '_' . basename($_FILES['logo']['name']);
        $upload_dir = "uploaded_logo/";
        
        // Create directory if it doesn't exist
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        
        $target_path = $upload_dir . $logo_name;
        
        if (!move_uploaded_file($_FILES['logo']['tmp_name'], $target_path)) {
            throw new Exception("Failed to upload logo");
        }
    } else {
        throw new Exception("No logo uploaded or upload error");
    }

    // Fetch form fields safely
    $company_name = $_POST['company_name'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $facebook = $_POST['facebook'] ?? '';
    $linkedin = $_POST['linkedin'] ?? '';
    $twitter = $_POST['twitter'] ?? '';
    $instagram = $_POST['instagram'] ?? '';
    $mobile = $_POST['mobile'] ?? '';
    $address = $_POST['address'] ?? '';

    // Validate required fields
    if (empty($company_name) || empty($email) || empty($password)) {
        throw new Exception("Required fields are missing");
    }

    // Hash the password for security
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Insert data
    $stmt = $conn->prepare("INSERT INTO users (company_name, email, password, facebook, linkedin, twitter, instagram, mobile, address, logo_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    
    if (!$stmt) {
        throw new Exception("Prepare failed: " . $conn->error);
    }
    
    $stmt->bind_param("ssssssssss", $company_name, $email, $hashed_password, $facebook, $linkedin, $twitter, $instagram, $mobile, $address, $logo_name);

    if ($stmt->execute()) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Registration successful',
            'logo_path' => $logo_name
        ]);
    } else {
        throw new Exception("Error: " . $stmt->error);
    }

} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
} finally {
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?> 