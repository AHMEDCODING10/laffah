# Production Dockerfile for Laffah API & Admin Panel
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and required PHP extension libraries (MySQL + PostgreSQL support)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    zip \
    unzip \
    git \
    curl \
    supervisor \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql pdo_pgsql pgsql mbstring exif pcntl bcmath gd zip opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache Rewrite, Headers, and Proxy modules for Reverb WebSockets
RUN a2enmod rewrite headers proxy proxy_http proxy_wstunnel && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Install Node.js 22.x for Vite assets build
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy composer files first for optimal caching
COPY composer.json composer.lock ./

# Install PHP dependencies without dev packages
RUN composer install --no-dev --no-interaction --no-scripts --optimize-autoloader --prefer-dist

# Copy the entire backend codebase
COPY . .

# Install frontend dependencies and build Vite / Livewire assets
RUN if [ -f package.json ]; then \
        npm ci --no-audit --prefer-offline || npm install; \
        npm run build; \
    fi

# Complete Composer autoloader generation
RUN composer dump-autoload --optimize --no-dev

# Configure Apache DocumentRoot to point to /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set permissions for Laravel storage and cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Fix line endings (CRLF to LF) and make start.sh executable
RUN sed -i 's/\r$//' /var/www/html/start.sh && chmod +x /var/www/html/start.sh

# Expose default port (dynamic $PORT applied at runtime by start.sh)
EXPOSE 80 8080

# Run entrypoint startup script
CMD ["/var/www/html/start.sh"]
