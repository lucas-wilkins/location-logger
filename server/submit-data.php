<?php
header('Content-Type: application/json; charset=utf-8');

function respond($success, $message, $statusCode = 200) {
    http_response_code($statusCode);

    echo json_encode([
        'success' => $success,
        'message' => $message
    ]);

    exit;
}

// Read incoming JSON
$json = file_get_contents('php://input');

// Validate JSON
$data = json_decode($json, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    respond(false, 'Invalid JSON supplied', 400);
}

// Check the password

// Check password field
if (!isset($data['password']) || $data['password'] !== 'password') {
    respond(false, 'Invalid or missing password', 401);
}

// Check for username
if (!isset($data['user'])) {
    respond(false, 'No username field', 400);
}

$username = $data['user'];

// Generate file name

$directory = '/data/';
$username = preg_replace('/[^a-zA-Z0-9_-]/', '_', trim($username));

$timestamp = date('Y-m-d_H-i-s');

$uid = bin2hex(random_bytes(3));

$file = $directory . $timestamp . '_' . $uid . '_' .$username . '.json';

// Save the data
$result = file_put_contents(
    $file,
    json_encode($data, JSON_PRETTY_PRINT),
    LOCK_EX
);

if ($result === false) {
    respond(false, 'Failed to save file', 500);
}

// Report success
respond(true, 'File saved successfully');
?>