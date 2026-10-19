<?php

// Displays a list of uploaded submissions

$dir = '/data';
$files = glob($dir . '/*.json');
$entries = [];

foreach ($files as $file) {
    $filename = basename($file);

    if (preg_match(
        '/^(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})_([^_]+)_(.+)\.json$/',
        $filename,
        $matches
    )) {
        $date = $matches[1];
        $time = str_replace('-', ':', $matches[2]);

        $entries[] = [
            'timestamp' => $date . ' ' . $time,
            'uid'       => $matches[3],
            'username'  => $matches[4],
        ];
    }
}

// Sort chronologically, oldest first
usort($entries, function ($a, $b) {
    return strcmp($a['timestamp'], $b['timestamp'])
        ?: strcmp($a['uid'], $b['uid']);
});

// Display results in an HTML table
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>JSON Files</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 30px;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            max-width: 800px;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 10px 12px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #eee;
        }
    </style>
</head>
<body>

<h2>Submissions (<?= count($entries) ?>)</h2>

<table>
    <thead>
        <tr>
            <th>UID</th>
            <th>Date/Time</th>
            <th>User</th>
        </tr>
    </thead>
    <tbody>
        <?php foreach ($entries as $entry): ?>
            <tr>
                <td><?= htmlspecialchars($entry['uid'], ENT_QUOTES, 'UTF-8') ?></td>
                <td><?= htmlspecialchars($entry['timestamp'], ENT_QUOTES, 'UTF-8') ?></td>
                <td><?= htmlspecialchars($entry['username'], ENT_QUOTES, 'UTF-8') ?></td>
            </tr>
        <?php endforeach; ?>
    </tbody>
</table>