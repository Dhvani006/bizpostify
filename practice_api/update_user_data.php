<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Get user ID from the request
    $user_id = $data['user_id'] ?? null;
    
    if (!$user_id) {
        echo json_encode(['status' => 'error', 'message' => 'User ID is required']);
        exit;
    }

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
        $data['company_name'],
        $data['email'],
        $data['mobile'],
        $data['address'],
        $data['facebook'],
        $data['linkedin'],
        $data['twitter'],
        $data['instagram']
    ];

    // Handle logo upload if provided
    if (isset($_FILES['logo']) && $_FILES['logo']['error'] === UPLOAD_ERR_OK) {
        $logo = $_FILES['logo'];
        $logo_name = time() . '_' . $logo['name'];
        $logo_path = 'uploads/' . $logo_name;
        
        if (move_uploaded_file($logo['tmp_name'], $logo_path)) {
            $query .= ", logo_path = ?";
            $params[] = $logo_path;
        }
    }

    $query .= " WHERE id = ?";
    $params[] = $user_id;

    try {
        $stmt = $conn->prepare($query);
        $stmt->execute($params);

        if ($stmt->rowCount() > 0) {
            echo json_encode([
                'status' => 'success',
                'message' => 'Profile updated successfully'
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'No changes made or user not found'
            ]);
        }
    } catch (PDOException $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Database error: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid request method'
    ]);
}
?> 