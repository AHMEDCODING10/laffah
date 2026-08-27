<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\CaptainProfile;
use App\Models\Wallet;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Ensure roles exist for web and api guards
        $webAdminRole = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);
        $apiAdminRole = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'api']);

        Role::firstOrCreate(['name' => 'captain', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'captain', 'guard_name' => 'api']);
        Role::firstOrCreate(['name' => 'passenger', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'passenger', 'guard_name' => 'api']);

        $admins = [
            [
                'name' => 'ahmed',
                'email' => 'ahmed@laffah.com',
                'phone' => '770291452',
                'password' => bcrypt('770291452'),
            ],
            [
                'name' => 'mohammed',
                'email' => 'mohammed@laffah.com',
                'phone' => '775906034',
                'password' => bcrypt('775906034'),
            ],
            [
                'name' => 'مدير النظام',
                'email' => 'admin@laffah.com',
                'phone' => '770000000',
                'password' => bcrypt('12345678'),
            ]
        ];

        foreach ($admins as $adminData) {
            $admin = User::firstOrCreate(
                ['phone' => $adminData['phone']],
                [
                    'name' => $adminData['name'],
                    'email' => $adminData['email'],
                    'password' => $adminData['password'],
                    'is_active' => true,
                ]
            );
            if (!$admin->hasRole('admin')) {
                try { $admin->assignRole($webAdminRole); } catch (\Exception $e) {}
                try { $admin->assignRole($apiAdminRole); } catch (\Exception $e) {}
            }
        }

        // Test Passenger
        $passenger = User::firstOrCreate(
            ['phone' => '771111111'],
            [
                'name' => 'راكب تجريبي',
                'email' => 'passenger@laffah.com',
                'password' => bcrypt('12345678'),
                'is_active' => true,
            ]
        );
        $passengerRole = Role::where('name', 'passenger')->where('guard_name', 'api')->first();
        if ($passengerRole && !$passenger->hasRole('passenger')) {
            try { $passenger->assignRole($passengerRole); } catch (\Exception $e) {}
        }
        Wallet::firstOrCreate(
            ['user_id' => $passenger->id],
            ['balance' => 50000, 'currency' => 'YER']
        );

        // Test Captain
        $captainUser = User::firstOrCreate(
            ['phone' => '772222222'],
            [
                'name' => 'كابتن تجريبي',
                'email' => 'captain@laffah.com',
                'password' => bcrypt('12345678'),
                'is_active' => true,
            ]
        );
        $captainRole = Role::where('name', 'captain')->where('guard_name', 'api')->first();
        if ($captainRole && !$captainUser->hasRole('captain')) {
            try { $captainUser->assignRole($captainRole); } catch (\Exception $e) {}
        }
        $captainProfile = CaptainProfile::firstOrCreate(
            ['user_id' => $captainUser->id],
            [
                'is_online' => true,
                'is_verified' => true,
                'vehicle_type' => 'motorcycle',
                'vehicle_model' => 'Honda 2024',
                'plate_number' => '12345-ص',
                'vehicle_color' => 'أسود',
                'rating' => 4.9,
            ]
        );
        Wallet::firstOrCreate(
            ['user_id' => $captainUser->id],
            ['balance' => 25000, 'currency' => 'YER']
        );
        \App\Models\CaptainLocation::updateOrCreate(
            ['captain_profile_id' => $captainProfile->id],
            ['latitude' => 15.3694, 'longitude' => 44.1910]
        );
    }
}

