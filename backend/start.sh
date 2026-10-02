#!/bin/bash
set -e

echo "🚀 [Laffah] Starting Production Environment Setup..."

# 1. Adapt Apache port to Render / Railway / Custom dynamic $PORT
if [ -n "$PORT" ]; then
    echo "⚡ [Laffah] Binding Apache to dynamic PORT: $PORT"
    sed -i "s/Listen 80/Listen $PORT/g" /etc/apache2/ports.conf
    sed -i "s/VirtualHost \*:80/VirtualHost \*:$PORT/g" /etc/apache2/sites-available/000-default.conf
else
    echo "⚡ [Laffah] Using standard port 80"
fi

# Configure proxy for Reverb Websockets
echo "📡 [Laffah] Configuring Apache to proxy Reverb WebSockets..."
sed -i '/<\/VirtualHost>/i \
    ProxyPass "/app" "ws://127.0.0.1:8080/app"\n\
    ProxyPassReverse "/app" "ws://127.0.0.1:8080/app"\n\
    ProxyPass "/apps" "http://127.0.0.1:8080/apps"\n\
    ProxyPassReverse "/apps" "http://127.0.0.1:8080/apps"\n' /etc/apache2/sites-available/000-default.conf

# 2. Run Database Migrations & Symlinks
echo "📦 [Laffah] Running database migrations..."
php artisan migrate --force || echo "⚠️ Migration warning, continuing..."

echo "🔗 [Laffah] Creating storage symlink..."
php artisan storage:link || true

# 3. Seed default system settings if table is empty
echo "⚙️ [Laffah] Verifying system settings..."
php artisan db:seed --class=DatabaseSeeder --force || true

# 4. Production Optimizations & Caching
echo "⚡ [Laffah] Optimizing caches..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true
php artisan event:cache || true

# 5. Launch Laravel Reverb Real-Time WebSockets Engine in Background
if [ "$ENABLE_REVERB" != "false" ]; then
    echo "📡 [Laffah] Starting Laravel Reverb WebSocket Server..."
    nohup php artisan reverb:start --host=0.0.0.0 --port=8080 > /var/www/html/storage/logs/reverb.log 2>&1 &
fi

# 6. Launch Queue Worker in Background with Auto-Restart (Self-Healing)
if [ "$ENABLE_QUEUE" != "false" ]; then
    echo "⏳ [Laffah] Starting Queue Worker with Auto-Restart..."
    nohup bash -c 'while true; do php artisan queue:work --sleep=3 --tries=3; echo "Queue crashed. Restarting in 5s..."; sleep 5; done' > /var/www/html/storage/logs/queue.log 2>&1 &
fi

echo "✅ [Laffah] Startup completed successfully. Launching Web Server..."

# 7. Start Apache Web Server in Foreground
exec apache2-foreground
