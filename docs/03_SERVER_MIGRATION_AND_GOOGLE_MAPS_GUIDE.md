# 🛠️ دليل النقل والترحيل الفني الشامل والتحول إلى خرائط Google Maps
## المرجع الهندسي المتكامل لنشر منصة «لفّة» على سيرفر الشركة المستثمرة
**إعداد الإدارة الفنية والتقنية | مرجع إرشادي لفريق الـ DevOps ومطوري الموبايل**

---

## 1. متطلبات بيئة السيرفر ونظام التشغيل (Server Requirements)

* **نظام التشغيل الموصى به:** Ubuntu 22.04 LTS أو 24.04 LTS (خادم نظيف أو سيرفر مشترك).
* **حزم البرمجيات المطلوبة:**
  * **PHP:** الإصدار 8.2 أو 8.3 مع الامتدادات (`php-fpm`, `php-mysql`, `php-mbstring`, `php-xml`, `php-curl`, `php-bcmath`, `php-redis`, `php-zip`, `php-gd`, `php-intl`).
  * **قاعدة البيانات:** MySQL 8.0+ أو MariaDB 10.11+.
  * **خادم الويب:** Nginx 1.18+.
  * **الذاكرة المؤقتة:** Redis Server 6.0+.
  * **مدير العمليات في الخلفية:** Supervisor (لتشغيل طوابير المهام وخادم Reverb WebSockets).
  * **إدارة الحزم:** Composer 2.x و Node.js 20.x + NPM.
  * **شهادات التشفير:** Certbot (Let's Encrypt SSL).

---

## 2. خطوات التثبيت والإعداد على السيرفر سطر بسطر (Full Server Setup Commands)

### 2.1 تثبيت البرمجيات الأساسية
```bash
# تحديث مستودعات النظام
sudo apt update && sudo apt upgrade -y

# تثبيت الأدوات المساعدة
sudo apt install -y curl git unzip zip software-properties-common ufw supervisor redis-server nginx

# إضافة مستودع PHP وتثبيت الإصدار 8.2 وملحقاته
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml \
    php8.2-curl php8.2-bcmath php8.2-redis php8.2-zip php8.2-gd php8.2-intl

# تثبيت Composer عالمياً
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# تثبيت Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

---

### 2.2 إعداد قاعدة البيانات (MySQL Configuration)
```bash
# تسجيل الدخول إلى MySQL
sudo mysql

# تنفيذ أوامر إنشاء قاعدة البيانات ومستخدم خاص بتطبيق لفّة:
CREATE DATABASE laffah_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'laffah_user'@'localhost' IDENTIFIED BY 'StrongSecretPassword2026!';
GRANT ALL PRIVILEGES ON laffah_db.* TO 'laffah_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

### 2.3 رفع كود الباك إند وضبط الصلاحيات (Deploy Backend Code)
```bash
# إنشاء مجلد المشروع في السيرفر
sudo mkdir -p /var/www/laffah
sudo chown -R $USER:www-data /var/www/laffah

# استنساخ أو رفع كود الباك إند داخل /var/www/laffah/backend
# الانتقال إلى المجلد وتثبيت الاعتماديات
cd /var/www/laffah/backend
composer install --no-dev --optimize-autoloader

# نسخ ملف البيئة وتوليد المفاتيح
cp .env.example .env
php artisan key:generate
php artisan jwt:secret

# ضبط صلاحيات مجلدات التخزين والكاش
sudo chown -R www-data:www-data /var/www/laffah/backend/storage /var/www/laffah/backend/bootstrap/cache
sudo chmod -R 775 /var/www/laffah/backend/storage /var/www/laffah/backend/bootstrap/cache

# إنشاء الرابط الرمزي للصور المرفوعة
php artisan storage:link

# تشغيل قواعد البيانات وتوليد البيانات الأولية
php artisan migrate --force
php artisan db:seed --force
```

---

### 2.4 إعداد Supervisor لطوابير المهام وخادم Reverb اللحظي

أنشئ ملف إعدادات Supervisor:
```bash
sudo nano /etc/supervisor/conf.d/laffah.conf
```

ضع بداخل الملف المحتوى التالي:
```ini
[program:laffah-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/laffah/backend/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/laffah/backend/storage/logs/worker.log

[program:laffah-reverb]
process_name=%(program_name)s
command=php /var/www/laffah/backend/artisan reverb:start --host=127.0.0.1 --port=8085
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/laffah/backend/storage/logs/reverb.log
```

تفعيل وتشغيل المهام:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start all
sudo supervisorctl status
```

---

### 2.5 إعداد خادم Nginx والشهادة الأمنية SSL

أنشئ ملف تكوين الموقع الخاص بتطبيق لفّة:
```bash
sudo nano /etc/nginx/sites-available/api.laffah.com
```

الصق الإعدادات الاحترافية التالية (تدعم الـ API و WebSockets المشفر في نفس الوقت):
```nginx
server {
    listen 80;
    server_name api.laffah.com; # استبدله بالنطاق الفعلي
    root /var/www/laffah/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;
    charset utf-8;

    # 1. توجيه اتصالات الـ WebSockets (Laravel Reverb)
    location /app {
        proxy_pass http://127.0.0.1:8085;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }

    # 2. توجيه طلبات لوحة التحكم وتطبيقات الـ API
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

تفعيل الموقع وتوليد شهادة الحماية SSL:
```bash
sudo ln -s /etc/nginx/sites-available/api.laffah.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# توليد شهادة SSL مجانية وتلقائية التجديد
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.laffah.com
```

---

## 3. قائمة المتغيرات والبيانات التي يجب تغييرها عند النقل (Migration Checklist)

### 3.1 المتغيرات في ملف الباك إند (`backend/.env`)

```ini
# إعدادات التطبيق العامة
APP_NAME="لفّة"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.laffah.com # رابط الدومين الرسمي الجديد

# إعدادات قاعدة البيانات الجديدة بالسيرفر
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laffah_db
DB_USERNAME=laffah_user
DB_PASSWORD=StrongSecretPassword2026!

# إعدادات الكاش والطوابير
CACHE_STORE=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_PREFIX=laffah_prod_

# إعدادات الـ WebSockets (Laravel Reverb) للإنتاج
BROADCAST_CONNECTION=reverb
PUSHER_APP_ID=laffah_live_id
PUSHER_APP_KEY=laffah_live_key_99
PUSHER_APP_SECRET=laffah_live_secret_2026
PUSHER_HOST=api.laffah.com
PUSHER_PORT=443
PUSHER_SCHEME=https

REVERB_APP_ID=laffah_live_id
REVERB_APP_KEY=laffah_live_key_99
REVERB_APP_SECRET=laffah_live_secret_2026
REVERB_HOST=127.0.0.1
REVERB_PORT=8085
REVERB_SCHEME=http

# مفتاح Firebase الخاص بحساب الشركة (يتم وضع ملف الـ json في هذا المسار)
FIREBASE_CREDENTIALS=storage/app/firebase/service-account.json

# إعدادات خدمة رسائل التوثيق WhatsApp Cloud API
META_WHATSAPP_PHONE_ID=ضع_هنا_رقم_الهوية_الخاص_بواتساب_الشركة
META_WHATSAPP_TOKEN=ضع_هنا_الرمز_السري_الدائم_من_ميتا
```

بعد تعديل الملف، قم دائماً بتنفيذ أوامر الكاش للإنتاج:
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

### 3.2 التعديلات في تطبيق الموبايل (Flutter Mobile App)

1. **تحديث ملف `laffah/.env`:**
   ```ini
   API_BASE_URL=https://api.laffah.com/api
   PUSHER_APP_ID=laffah_live_id
   PUSHER_APP_KEY=laffah_live_key_99
   PUSHER_APP_CLUSTER=mt1
   USE_REVERB=true
   ```

2. **تغيير اسم الحزمة والهوية الرسمية (Package Name / Bundle ID):**
   * **للأندرويد:** في ملف `laffah/android/app/build.gradle`:
     قم بتعديل `applicationId "com.laffah.app"` إلى المعرف الجديد المعتمد من قبل الشركة (مثلاً: `com.company.laffah`).
   * **للـ iOS:** في `laffah/ios/Runner.xcodeproj/project.pbxproj`:
     قم بتعديل `PRODUCT_BUNDLE_IDENTIFIER = com.company.laffah;`.

3. **تحديث ملفات إعدادات Firebase:**
   * في مشروع Firebase الجديد الخاص بالشركة: أنشئ تطبيقين (Android و iOS).
   * حمل ملف `google-services.json` وضعه في المجلد:
     `laffah/android/app/google-services.json`
   * حمل ملف `GoogleService-Info.plist` وضعه في المجلد:
     `laffah/ios/Runner/GoogleService-Info.plist`

---

## 4. الدليل العملي الكامل للتحول إلى خرائط Google Maps

إذا رغبت الشركة المستثمرة في استخدام خرائط قوقل بدلاً من الخرائط الحالية، إليك الخطوات التقنية الدقيقة لتطبيق ذلك:

### 4.1 خطوات إعداد Google Cloud Console
1. الدخول إلى [Google Cloud Console](https://console.cloud.google.com/) وإنشاء مشروع جديد باسم **Laffah Transport**.
2. الذهاب إلى **APIs & Services > Library** وتفعيل الخدمات التالية:
   * **Maps SDK for Android** (لعرض الخريطة على أجهزة أندرويد).
   * **Maps SDK for iOS** (لعرض الخريطة على أجهزة آيفون).
   * **Directions API** (لحساب المسارات، ورسم خط سير الرحلة المتعرج بين الكابتن والراكب).
   * **Geocoding API & Places API** (للبحث الذكي عن أسماء الشوارع والمباني).
3. الذهاب إلى **Credentials** وإنشاء **API Key**:
   * **تأمين المفتاح (Best Practice):**
     * قيد المفتاح الأول بتطبيقات الأندرويد فقط بواسطة (Package Name + SHA-1 Fingerprint).
     * قيد المفتاح الثاني بتطبيقات iOS فقط بواسطة (Bundle Identifier).

---

### 4.2 إضافة حزمة Google Maps في Flutter

في ملف `laffah/pubspec.yaml`:
```yaml
dependencies:
  google_maps_flutter: ^2.10.0
```
ثم تنفيذ:
```bash
flutter pub get
```

---

### 4.3 ضبط ملفات المنصة (Android & iOS)

* **في ملف `laffah/android/app/src/main/AndroidManifest.xml`:**
  أضف داخل وسم `<application>`:
  ```xml
  <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="ضع_هنا_مفتاح_قوقل_ماب_للأندرويد" />
  ```

* **في ملف `laffah/ios/Runner/AppDelegate.swift`:**
  ```swift
  import UIKit
  import Flutter
  import GoogleMaps

  @UIApplicationMain
  @objc class AppDelegate: FlutterAppDelegate {
    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      GMSServices.provideAPIKey("ضع_هنا_مفتاح_قوقل_ماب_للآيفون")
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
  }
  ```

---

### 4.4 الكود المصدري المحدث لمكون الخريطة (`laffah_map_view.dart`)

يمثل المكون `LaffahMapView` نقطة الوصول الموحدة للخريطة في كافة شاشات التطبيق (الرئيسية، شاشة تتبع الراكب، وشاشة الملاحة للكابتن). عند التبديل إلى Google Maps يتم تحويل الواجهة لتعمل بـ `GoogleMap` مع الاحتفاظ بجميع مزايا التتبع وسلاسة الحركة:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';

class LaffahMapView extends StatefulWidget {
  final LatLng? initialCenter;
  final double initialZoom;
  final LatLng? captainLocation;
  final double captainHeading;
  final LatLng? passengerLocation;
  final List<LatLng>? routePoints;
  final LatLng? dropoffLocation;
  final bool followCaptain;

  const LaffahMapView({
    super.key,
    this.initialCenter,
    this.initialZoom = 15.0,
    this.captainLocation,
    this.captainHeading = 0.0,
    this.passengerLocation,
    this.routePoints,
    this.dropoffLocation,
    this.followCaptain = false,
  });

  @override
  State<LaffahMapView> createState() => _LaffahMapViewState();
}

class _LaffahMapViewState extends State<LaffahMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const LatLng _sanaaCenter = LatLng(15.3694, 44.1910);

  @override
  void didUpdateWidget(covariant LaffahMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildMarkers();
    _buildPolylines();

    // متابعة الكابتن تلقائياً عند تحركه (Smart Follow Mode)
    if (widget.followCaptain && widget.captainLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: widget.captainLocation!,
            zoom: 16.5,
            bearing: widget.captainHeading,
          ),
        ),
      );
    }
  }

  void _buildMarkers() {
    final Set<Marker> newMarkers = {};

    // 1. ماركر موقع الراكب (نقطة الركوب)
    if (widget.passengerLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('passenger_pickup'),
          position: widget.passengerLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'نقطة الانطلاق'),
        ),
      );
    }

    // 2. ماركر الوجهة النهائية (نقطة النزول)
    if (widget.dropoffLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('dropoff_location'),
          position: widget.dropoffLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'الوجهة'),
        ),
      );
    }

    // 3. ماركر الكابتن مع زاوية التوجيه (Rotation / Bearing)
    if (widget.captainLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('captain_vehicle'),
          position: widget.captainLocation!,
          rotation: widget.captainHeading,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'موقع الكابتن'),
        ),
      );
    }

    setState(() => _markers = newMarkers);
  }

  void _buildPolylines() {
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('trip_route'),
            points: widget.routePoints!,
            color: AppColors.primaryYellow,
            width: 5,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialCenter ?? widget.captainLocation ?? widget.passengerLocation ?? _sanaaCenter,
        zoom: widget.initialZoom,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _buildMarkers();
        _buildPolylines();
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
    );
  }
}
```

---

## 5. خطة النسخ الاحتياطي التلقائي والصيانة الدورية (Backup & Monitoring)

لضمان سلامة بيانات الشركة والمستخدمين، يتم تفعيل نسخ احتياطي يومي لقواعد البيانات والصور:

أنشئ سكربت النسخ الاحتياطي:
```bash
sudo nano /usr/local/bin/backup-laffah.sh
```
ضع بداخله:
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/laffah"
mkdir -p $BACKUP_DIR
DATE=$(date +%Y-%m-%d_%H%M%S)

# أخذ نسخة احتياطية من قاعدة البيانات وضغطها
mysqldump -u laffah_user -p'StrongSecretPassword2026!' laffah_db | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# حذف النسخ الاحتياطية الأقدم من 14 يوماً تلقائياً لتوفير المساحة
find $BACKUP_DIR -type f -mtime +14 -name "*.sql.gz" -exec rm {} \;
```

اجعله قابلاً للتنفيذ وضعه في المهام المجدولة (Cron Job):
```bash
sudo chmod +x /usr/local/bin/backup-laffah.sh
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/backup-laffah.sh") | crontab -
```
*(يقوم هذا السكربت بعمل نسخة احتياطية تلقائية يومياً عند الساعة 3:00 فجراً).*
