<?php

// Simulate captain moving south on a street in Sanaa
$captainId = 1;
$startLat = 15.3500;
$startLng = 44.2000;

for ($i = 0; $i < 20; $i++) {
    $lat = $startLat - ($i * 0.0005);
    $lng = $startLng + ($i * 0.0001);
    
    // Simulate motorcycle heading south-east
    $heading = 135; 

    echo "Sending Location: $lat, $lng, Heading: $heading\n";

    $ch = curl_init('http://127.0.0.1:8000/api/tracking/' . $captainId . '/location');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
        'lat' => $lat,
        'lng' => $lng,
        'heading' => $heading
    ]));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);

    $response = curl_exec($ch);
    curl_close($ch);
    echo "Response: $response\n";

    sleep(2);
}
echo "Simulation Finished.\n";
