<?php

 $con=mysqli_connect("localhost","root","","festival_card");

 if (isset($_FILES['frameImage'])) {
    $file_name = $_FILES['frameImage']['name'];
    $tempname = $_FILES['frameImage']['tmp_name'];
    $folder = 'Frame_images/' . $file_name; // Images folder should exist already

    if (move_uploaded_file($tempname, $folder)) {
        // Now insert into database
        $query = mysqli_query($con, "INSERT INTO frame (img) VALUES ('$file_name')");

        if ($query) {
            echo "Frame uploaded and saved to database!";
        } else {
            echo "Database insertion failed!";
        }
    } else {
        echo "Failed to upload frame!";
    }
} else {
    echo "No file received!";
}

?>