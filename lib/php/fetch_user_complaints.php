<?php

// Database connection parameters
$servername = "localhost";
$username = "your_username";
$password = "your_password";
$database = "metroabet";

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Fetch user complaints
$user_id = $_GET['user_id']; // Assuming you're passing user_id as a query parameter
$sql = "SELECT * FROM complaint WHERE u_id = $user_id";
$result = $conn->query($sql);

// Check if there are any complaints
if ($result->num_rows > 0) {
    $complaints = array();
    // Output data of each row
    while($row = $result->fetch_assoc()) {
        // Add complaint data to the array
        $complaints[] = $row;
    }
    // Output JSON encoded array
    echo json_encode($complaints);
} else {
    echo "0 results";
}

// Close connection
$conn->close();

?>
