#!/bin/bash

# Laravel Docker Compose Generator
# Generate docker-compose.yml based on configuration

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse arguments
PROJECT_NAME=$1
LARAVEL_VERSION=$2
PHP_VERSION=$3
DB_TYPE=$4
DB_USERNAME=$5
DB_PASSWORD=$6
DB_NAME=$7
DB_PORT=$8
REDIS_ENABLED=$9
REDIS_PORT=${10}
NGINX_HTTP_PORT=${11}
NGINX_HTTPS_PORT=${12}
NGINX_SSL=${13}
NGINX_CACHE=${14}
NGINX_RATE_LIMIT=${15}
MAIL_CATCHER=${16}
XDEBUG=${17}
QUEUE_WORKER=${18}
DB_ADMIN=${19}
HOT_RELOAD=${20}
PRESET=${21}

# Set defaults
PROJECT_NAME=${PROJECT_NAME:-laravel-app}
LARAVEL_VERSION=${LARAVEL_VERSION:-latest}
PHP_VERSION=${PHP_VERSION:-8.3}
DB_TYPE=${DB_TYPE:-mysql}
DB_USERNAME=${DB_USERNAME:-root}
DB_PASSWORD=${DB_PASSWORD:-root}
DB_NAME=${DB_NAME:-$PROJECT_NAME}
DB_PORT=${DB_PORT:-3306}
REDIS_ENABLED=${REDIS_ENABLED:-false}
REDIS_PORT=${REDIS_PORT:-6379}
NGINX_HTTP_PORT=${NGINX_HTTP_PORT:-80}
NGINX_HTTPS_PORT=${NGINX_HTTPS_PORT:-443}
NGINX_SSL=${NGINX_SSL:-false}
NGINX_CACHE=${NGINX_CACHE:-false}
NGINX_RATE_LIMIT=${NGINX_RATE_LIMIT:-false}
MAIL_CATCHER=${MAIL_CATCHER:-false}
XDEBUG=${XDEBUG:-false}
QUEUE_WORKER=${QUEUE_WORKER:-false}
DB_ADMIN=${DB_ADMIN:-}
HOT_RELOAD=${HOT_RELOAD:-false}
PRESET=${PRESET:-custom}

# Determine database image
if [ "$DB_TYPE" = "postgresql" ]; then
    DB_IMAGE="postgres:16-alpine"
    DB_PORT=${DB_PORT:-5432}
else
    DB_IMAGE="mysql:8.0"
    DB_PORT=${DB_PORT:-3306}
fi

# Create project directory
PROJECT_DIR="$(pwd)/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR"

echo -e "${BLUE}Generating docker-compose.yml for $PROJECT_NAME...${NC}"

# Generate docker-compose.yml
cat > "$PROJECT_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  # PHP-FPM Service
  php:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${PROJECT_NAME}-php
    working_dir: /var/www/html
    volumes:
      - ./:/var/www/html
      - ./php.ini:/usr/local/etc/php/conf.d/custom.ini
    networks:
      - ${PROJECT_NAME}-network
    depends_on:
      - db
$([ "$REDIS_ENABLED" = "true" ] && echo "      - redis" || echo "")
    environment:
      - PHP_VERSION=${PHP_VERSION}
      - XDEBUG_ENABLED=${XDEBUG}

  # Nginx Service
  nginx:
    image: nginx:alpine
    container_name: ${PROJECT_NAME}-nginx
    ports:
      - "${NGINX_HTTP_PORT}:80"
$([ "$NGINX_SSL" = "true" ] && echo "      - \"${NGINX_HTTPS_PORT}:443\"" || echo "")
    volumes:
      - ./:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
$([ "$NGINX_SSL" = "true" ] && echo "      - ./ssl:/etc/nginx/ssl" || echo "")
    networks:
      - ${PROJECT_NAME}-network
    depends_on:
      - php

  # Database Service
  db:
    image: ${DB_IMAGE}
    container_name: ${PROJECT_NAME}-db
    ports:
      - "${DB_PORT}:${DB_PORT}"
    environment:
EOF

# Add database environment variables
if [ "$DB_TYPE" = "postgresql" ]; then
    cat >> "$PROJECT_DIR/docker-compose.yml" << EOF
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
EOF
else
    cat >> "$PROJECT_DIR/docker-compose.yml" << EOF
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USERNAME}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
EOF
fi

cat >> "$PROJECT_DIR/docker-compose.yml" << EOF
    volumes:
      - ${PROJECT_NAME}-db-data:/var/lib/mysql
    networks:
      - ${PROJECT_NAME}-network
EOF

# Add Redis service
if [ "$REDIS_ENABLED" = "true" ]; then
    cat >> "$PROJECT_DIR/docker-compose.yml" << EOF

  # Redis Service
  redis:
    image: redis:7-alpine
    container_name: ${PROJECT_NAME}-redis
    ports:
      - "${REDIS_PORT}:6379"
    volumes:
      - ${PROJECT_NAME}-redis-data:/data
    networks:
      - ${PROJECT_NAME}-network
    command: redis-server --appendonly yes
EOF
fi

# Add Mail Catcher
if [ "$MAIL_CATCHER" = "true" ]; then
    cat >> "$PROJECT_DIR/docker-compose.yml" << EOF

  # MailHog Service
  mailhog:
    image: mailhog/mailhog:latest
    container_name: ${PROJECT_NAME}-mailhog
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - ${PROJECT_NAME}-network
EOF
fi

# Add phpMyAdmin
if [ "$DB_ADMIN" = "phpmyadmin" ] && [ "$DB_TYPE" = "mysql" ]; then
    cat >> "$PROJECT_DIR/docker-compose.yml" << EOF

  # phpMyAdmin Service
  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: ${PROJECT_NAME}-phpmyadmin
    ports:
      - "8080:80"
    environment:
      PMA_HOST: db
      PMA_USER: ${DB_USERNAME}
      PMA_PASSWORD: ${DB_PASSWORD}
    networks:
      - ${PROJECT_NAME}-network
    depends_on:
      - db
EOF
fi

# Add Adminer
if [ "$DB_ADMIN" = "adminer" ]; then
    cat >> "$PROJECT_DIR/docker-compose.yml" << EOF

  # Adminer Service
  adminer:
    image: adminer:latest
    container_name: ${PROJECT_NAME}-adminer
    ports:
      - "8080:8080"
    networks:
      - ${PROJECT_NAME}-network
    depends_on:
      - db
EOF
fi

# Add Queue Worker
if [ "$QUEUE_WORKER" = "true" ]; then
    cat >> "$PROJECT_DIR/docker-compose.yml" << EOF

  # Queue Worker Service
  queue:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${PROJECT_NAME}-queue
    working_dir: /var/www/html
    volumes:
      - ./:/var/www/html
    networks:
      - ${PROJECT_NAME}-network
    depends_on:
      - db
      - php
    command: php artisan queue:work --verbose --tries=3 --timeout=90
EOF
fi

# Add volumes and networks
cat >> "$PROJECT_DIR/docker-compose.yml" << EOF

volumes:
  ${PROJECT_NAME}-db-data:
$([ "$REDIS_ENABLED" = "true" ] && echo "  ${PROJECT_NAME}-redis-data:" || echo "")

networks:
  ${PROJECT_NAME}-network:
    driver: bridge
EOF

echo -e "${GREEN}✓ Generated docker-compose.yml${NC}"

# Generate Dockerfile
cat > "$PROJECT_DIR/Dockerfile" << EOF
FROM php:${PHP_VERSION}-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    git \\
    curl \\
    libpng-dev \\
    libonig-dev \\
    libxml2-dev \\
    zip \\
    unzip \\
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Expose port 9000 for PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
EOF

echo -e "${GREEN}✓ Generated Dockerfile${NC}"

# Generate php.ini
cat > "$PROJECT_DIR/php.ini" << EOF
[PHP]
upload_max_filesize = 64M
post_max_size = 64M
memory_limit = 256M
max_execution_time = 300
max_input_vars = 3000

[Date]
date.timezone = UTC
EOF

if [ "$XDEBUG" = "true" ]; then
    cat >> "$PROJECT_DIR/php.ini" << EOF

[xdebug]
xdebug.mode=debug,develop
xdebug.start_with_request=yes
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.log=/var/www/html/storage/logs/xdebug.log
EOF
fi

echo -e "${GREEN}✓ Generated php.ini${NC}"

# Generate nginx.conf (will be created from template)
if [ -f "$BASE_DIR/templates/nginx-laravel.conf" ]; then
    cp "$BASE_DIR/templates/nginx-laravel.conf" "$PROJECT_DIR/nginx.conf"
    echo -e "${GREEN}✓ Generated nginx.conf${NC}"
else
    # Generate basic nginx.conf
    cat > "$PROJECT_DIR/nginx.conf" << EOF
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php index.html;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php:9000;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
    echo -e "${GREEN}✓ Generated basic nginx.conf${NC}"
fi

# Generate .env file
if [ -f "$BASE_DIR/utils/env-manager.sh" ]; then
    source "$BASE_DIR/utils/env-manager.sh"
    generate_env_file \
        "$PROJECT_NAME" \
        "$PROJECT_NAME" \
        "$DB_TYPE" \
        "db" \
        "$DB_PORT" \
        "$DB_NAME" \
        "$DB_USERNAME" \
        "$DB_PASSWORD" \
        "$REDIS_ENABLED" \
        "redis" \
        "$REDIS_PORT" \
        "http://localhost:$NGINX_HTTP_PORT" \
        "mailhog" \
        "1025" \
        "$PROJECT_DIR/.env"
    echo -e "${GREEN}✓ Generated .env file${NC}"
fi

# Generate PORT_MAPPING.txt
cat > "$PROJECT_DIR/PORT_MAPPING.txt" << EOF
Port Mapping for ${PROJECT_NAME}
===============================

Nginx HTTP:  ${NGINX_HTTP_PORT}
Nginx HTTPS: ${NGINX_HTTPS_PORT}
Database:    ${DB_PORT}
EOF

if [ "$REDIS_ENABLED" = "true" ]; then
    echo "Redis:        ${REDIS_PORT}" >> "$PROJECT_DIR/PORT_MAPPING.txt"
fi

if [ "$MAIL_CATCHER" = "true" ]; then
    echo "MailHog SMTP: 1025" >> "$PROJECT_DIR/PORT_MAPPING.txt"
    echo "MailHog UI:   8025" >> "$PROJECT_DIR/PORT_MAPPING.txt"
fi

if [ -n "$DB_ADMIN" ]; then
    echo "DB Admin:     8080" >> "$PROJECT_DIR/PORT_MAPPING.txt"
fi

echo -e "${GREEN}✓ Generated PORT_MAPPING.txt${NC}"

# Generate PROJECT_CONFIG.json
cat > "$PROJECT_DIR/PROJECT_CONFIG.json" << EOF
{
  "project_name": "${PROJECT_NAME}",
  "laravel_version": "${LARAVEL_VERSION}",
  "php_version": "${PHP_VERSION}",
  "database": {
    "type": "${DB_TYPE}",
    "host": "db",
    "port": ${DB_PORT},
    "database": "${DB_NAME}",
    "username": "${DB_USERNAME}"
  },
  "redis": {
    "enabled": ${REDIS_ENABLED},
    "port": ${REDIS_PORT}
  },
  "nginx": {
    "http_port": ${NGINX_HTTP_PORT},
    "https_port": ${NGINX_HTTPS_PORT},
    "ssl": ${NGINX_SSL},
    "cache": ${NGINX_CACHE},
    "rate_limit": ${NGINX_RATE_LIMIT}
  },
  "features": {
    "mail_catcher": ${MAIL_CATCHER},
    "xdebug": ${XDEBUG},
    "queue_worker": ${QUEUE_WORKER},
    "db_admin": "${DB_ADMIN}",
    "hot_reload": ${HOT_RELOAD},
    "preset": "${PRESET}"
  }
}
EOF

echo -e "${GREEN}✓ Generated PROJECT_CONFIG.json${NC}"

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ All files generated successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\n${CYAN}Next steps:${NC}"
echo "  1. cd $PROJECT_NAME"
echo "  2. docker-compose up -d"
echo "  3. docker-compose exec php composer install"
echo "  4. docker-compose exec php php artisan key:generate"
echo "  5. docker-compose exec php php artisan migrate"
echo -e "\n${CYAN}Access your application:${NC}"
echo "  http://localhost:$NGINX_HTTP_PORT"
if [ "$MAIL_CATCHER" = "true" ]; then
    echo "  MailHog UI: http://localhost:8025"
fi
if [ -n "$DB_ADMIN" ]; then
    echo "  DB Admin: http://localhost:8080"
fi
echo ""
