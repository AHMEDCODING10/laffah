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

        // Seed system default settings
        $defaultSettings = [
            ['key' => 'price_per_km',           'value' => '175',   'type' => 'number', 'group' => 'pricing'],
            ['key' => 'multi_stop_fee',         'value' => '300',   'type' => 'number', 'group' => 'pricing'],
            ['key' => 'commission_percent',     'value' => '15',    'type' => 'number', 'group' => 'pricing'],
            ['key' => 'parcel_percent_small',   'value' => '10',    'type' => 'number', 'group' => 'pricing'],
            ['key' => 'parcel_percent_medium',  'value' => '15',    'type' => 'number', 'group' => 'pricing'],
            ['key' => 'parcel_percent_large',   'value' => '20',    'type' => 'number', 'group' => 'pricing'],
            ['key' => 'app_name',               'value' => 'لَفَّة', 'type' => 'text',   'group' => 'general'],
            ['key' => 'support_phone',          'value' => '770291452', 'type' => 'text', 'group' => 'general'],
            ['key' => 'support_email',          'value' => 'support@laffah.com', 'type' => 'text', 'group' => 'general'],
            ['key' => 'search_radius_km',       'value' => '10',    'type' => 'number', 'group' => 'operational'],
            ['key' => 'min_withdrawal_amount',  'value' => '1000',  'type' => 'number', 'group' => 'operational'],
        ];

        // Delete obsolete keys
        \App\Models\Setting::whereIn('key', ['base_fare', 'max_captain_debt', 'min_fare', 'parcel_price_small', 'parcel_price_medium', 'parcel_price_large'])->delete();

        foreach ($defaultSettings as $s) {
            \App\Models\Setting::updateOrCreate(['key' => $s['key']], $s);
        }
    }
}

