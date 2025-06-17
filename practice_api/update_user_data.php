<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0); // Disable error display, we'll handle errors ourselves

// Include database connection
require_once 'db_connect.php';

// Log the request
error_log("Request received: " . print_r($_POST, true));
error_log("Files received: " . print_r($_FILES, true));

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get user ID from the request
    $user_id = $_POST['user_id'] ?? null;
    
    if (!$user_id) {
        error_log("Error: User ID not provided");
        echo json_encode(['status' => 'error', 'message' => 'User ID is required']);
        exit;
    }

    try {
        // Prepare the update query
        $query = "UPDATE users SET 
            company_name = ?,
            email = ?,
            mobile = ?,
            address = ?,
            facebook = ?,
            linkedin = ?,
            twitter = ?,
            instagram = ?";

        $params = [
            $_POST['company_name'] ?? '',
            $_POST['email'] ?? '',
            $_POST['mobile'] ?? '',
            $_POST['address'] ?? '',
            $_POST['facebook'] ?? '',
            $_POST['linkedin'] ?? '',
            $_POST['twitter'] ?? '',
            $_POST['instagram'] ?? ''
        ];

        $logo_path = null;

        // Handle logo upload if provided
        if (isset($_FILES['logo']) && $_FILES['logo']['error'] === UPLOAD_ERR_OK) {
            $logo = $_FILES['logo'];
            $logo_name = time() . '_' . $logo['name'];
            $upload_dir = 'uploaded_logo/';
            
            // Create uploads directory if it doesn't exist
            if (!is_dir($upload_dir)) {
                mkdir($upload_dir, 0777, true);
            }
            
            $logo_path = $upload_dir . $logo_name;
            
            if (move_uploaded_file($logo['tmp_name'], $logo_path)) {
                $query .= ", logo_path = ?";
                $params[] = $logo_path;
                error_log("Logo uploaded successfully to: " . $logo_path);
            } else {
                error_log("Failed to move uploaded file");
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Failed to upload logo'
                ]);
                exit;
            }
        }

        $query .= " WHERE id = ?";
        $params[] = $user_id;

        error_log("Executing query: " . $query);
        error_log("With params: " . print_r($params, true));

        $stmt = $conn->prepare($query);
        $stmt->execute($params);

        if ($stmt->rowCount() > 0) {
            error_log("Profile updated successfully");
            echo json_encode([
                'status' => 'success',
                'message' => 'Profile updated successfully',
                'logo_path' => $logo_path
            ]);
        } else {
            error_log("No changes made or user not found");
            echo json_encode([
                'status' => 'error',
                'message' => 'No changes made or user not found'
            ]);
        }
    } catch (PDOException $e) {
        error_log("Database error: " . $e->getMessage());
        echo json_encode([
            'status' => 'error',
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
} else {
    error_log("Invalid request method: " . $_SERVER['REQUEST_METHOD']);
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid request method'
    ]);
}
exit; // Add this to ensure no additional output
?> 