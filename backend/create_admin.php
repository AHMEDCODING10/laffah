<?php

require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

// Ensure roles exist
$webAdminRole = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);
$apiAdminRole = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'api']);

$admins = [
    [
        'name' => 'ahmed',
        'email' => 'ahmed@laffah.com',
        'phone' => '770291452',
        'password' => '770291452',
    ],
    [
        'name' => 'mohammed',
        'email' => 'mohammed@laffah.com',
        'phone' => '775906034',
        'password' => '775906034',
    ],
];

foreach ($admins as $adminData) {
    $user = User::updateOrCreate(
        ['phone' => $adminData['phone']],
        [
            'name' => $adminData['name'],
            'email' => $adminData['email'],
            'password' => Hash::make($adminData['password']),
            'is_active' => true,
        ]
    );

    try {
        $user->assignRole($webAdminRole);
    } catch (\Exception $e) {}

    try {
        $user->assignRole($apiAdminRole);
    } catch (\Exception $e) {}

    echo "Admin user '{$user->name}' ({$user->phone}) processed successfully.\n";
}

