<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Panel - Add Templates & Frames</title>
  <link rel="stylesheet" href="admin.css">
</head>
<body>
  <div class="container">
    <h1>Admin Panel</h1>

    <!-- Add Category -->
    <form action="addcategory.php" method="POST" target="hidden_iframe" onsubmit="setTimeout(() => location.reload(), 500);">
      <div class="form-section">
        <label>Add Category:</label>
        <input type="text" name="category" placeholder="Enter category name" required>
        <button type="submit" class="small-btn">Add Category</button>
      </div>
    </form>
    <iframe name="hidden_iframe" style="display:none;"></iframe>

    <!-- Add Template to Category -->
    <form action="addtemplate.php" method="POST" enctype="multipart/form-data" target="hidden_iframe" onsubmit="setTimeout(() => location.reload(), 500);">
      <div class="form-section">
        <label>Select Category:</label>
        <select name="category" required>
          <option value="">Select category</option>
          <?php
            // Connect to DB
            $conn = new mysqli("localhost", "root", "", "festival_card");
            if ($conn->connect_error) {
              die("Connection failed: " . $conn->connect_error);
            }

            // Fetch categories
            $result = $conn->query("SELECT name FROM categories");
            while ($row = $result->fetch_assoc()) {
              $value = strtolower(str_replace(' ', '_', $row['name']));
              echo "<option value='$value'>{$row['name']}</option>";
            }

            $conn->close();
          ?>
        </select>
        <input type="file" name="templateImage" accept="image/*" required>
        <button type="submit" class="small-btn">Insert Template</button>
      </div>
          </form><iframe name="hidden_iframe" style="display: none;"></iframe>
    <!-- Add Frame Image -->
    <h2>Add Frame</h2>
    <div class="image-grid" id="frameGrid">
      <!-- Frame images will appear here -->
    </div>
    <button class="add-btn" onclick="addFrameImage()">Add Frame Image</button>
  </div>

</body>
</html>
