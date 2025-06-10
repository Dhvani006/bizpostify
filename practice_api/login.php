<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Enable error logging
ini_set('display_errors', 1);
ini_set('log_errors', 1);
error_reporting(E_ALL);

// Database connection
$host = "localhost";
$user = "root";
$pass = "";
$db = "festival_card";

$response = array();

try {
    $conn = new mysqli($host, $user, $pass, $db);
    
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }

    // Get POST data and trim whitespace
    $email = trim($_POST['email'] ?? '');
    $password = trim($_POST['password'] ?? '');

    // Log received data (remove in production)
    error_log("Login attempt - Email: " . $email);
    error_log("Password length: " . strlen($password));

    if (empty($email) || empty($password)) {
        throw new Exception("Email and password are required");
    }

    // Prepare SQL statement to prevent SQL injection
    $stmt = $conn->prepare("SELECT id, email, password, company_name FROM users WHERE email = ?");
    if (!$stmt) {
        throw new Exception("Prepare failed: " . $conn->error);
    }
    
    $stmt->bind_param("s", $email);
    if (!$stmt->execute()) {
        throw new Exception("Execute failed: " . $stmt->error);
    }
    
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        throw new Exception("User not found");
    }

    $user = $result->fetch_assoc();

    // Debug logging (remove in production)
    error_log("Retrieved user data - Email: " . $user['email']);
    error_log("Stored password hash length: " . strlen($user['password']));
    error_log("First 10 chars of hash: " . substr($user['password'], 0, 10));
    
    // Check if the stored password is actually a hash
    if (strlen($user['password']) < 20 || !str_starts_with($user['password'], '$2y$')) {
        error_log("WARNING: Stored password does not appear to be a valid bcrypt hash");
    }

    // Verify password
    $verify_result = password_verify($password, $user['password']);
    error_log("Password verification result: " . ($verify_result ? "true" : "false"));

    if (!$verify_result) {
        error_log("Password verification failed for user: " . $email);
        throw new Exception("Invalid password");
    }

    // Login successful
    error_log("Login successful for user: " . $email);
    $response['status'] = 'success';
    $response['message'] = 'Login successful';
    $response['user_id'] = $user['id'];
    $response['email'] = $user['email'];
    $response['company_name'] = $user['company_name'];

} catch (Exception $e) {
    error_log("Login error: " . $e->getMessage());
    $response['status'] = 'error';
    $response['message'] = $e->getMessage();
} finally {
    if (isset($conn)) {
        $conn->close();
    }
    echo json_encode($response);
}
?> 