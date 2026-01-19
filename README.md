# 🐳 Dockerin - Interactive Docker CLI for Laravel

<div align="center">

**CLI Tool Interaktif untuk Setup Docker Laravel dengan Mudah dan Cepat**

[![GitHub](https://img.shields.io/badge/GitHub-irvandoda-blue)](https://github.com/irvandoda)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Quick Start](#-quick-start) • [Features](#-fitur-lengkap) • [Documentation](#-dokumentasi-lengkap) • [Examples](#-contoh-penggunaan) • [Troubleshooting](#-troubleshooting)

</div>

---

## 📖 Tentang Dockerin

**Dockerin** adalah Command Line Interface (CLI) tool interaktif yang dirancang khusus untuk mempermudah developer dalam membuat setup Docker untuk proyek Laravel. Dengan Dockerin, Anda tidak perlu lagi menulis `docker-compose.yml` secara manual. Cukup jawab beberapa pertanyaan interaktif, dan Dockerin akan menghasilkan konfigurasi Docker yang lengkap dan siap digunakan.

### ✨ Keunggulan

- 🚀 **Setup Cepat**: Generate docker-compose.yml dalam hitungan menit
- 🎯 **Interaktif**: CLI yang user-friendly dengan panduan step-by-step
- 🔧 **Lengkap**: Semua fitur yang dibutuhkan untuk development Laravel
- 🔄 **Auto-Detection**: Port management otomatis, tidak ada konflik port
- 📦 **Preset Templates**: API, SPA, Full-stack, dan Microservice
- 🌐 **Remote Execution**: Bisa dijalankan langsung dari GitHub tanpa download
- 💾 **Project Management**: Manage multiple projects dengan mudah

---

## 🚀 Quick Start

### Untuk Pemula (Paling Mudah)

**Langkah 1**: Install Dockerin (satu kali saja)

**Linux/Mac/Git Bash:**
```bash
bash <(curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/install.sh)
```

**Windows PowerShell:**
```powershell
# Opsi 1: Installer PowerShell (Recommended)
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/irvandoda/dockerin/main/install.ps1' -OutFile install.ps1
.\install.ps1

# Opsi 2: Alternative installer (jika opsi 1 gagal)
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/irvandoda/dockerin/main/install-windows.ps1' -OutFile install-windows.ps1
.\install-windows.ps1

# Opsi 3: One-liner (install.ps1)
powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/irvandoda/dockerin/main/install.ps1' -OutFile install.ps1; .\install.ps1"

# Opsi 4: One-liner (install-windows.ps1 - lebih reliable)
powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/irvandoda/dockerin/main/install-windows.ps1' -OutFile install-windows.ps1; .\install-windows.ps1"
```

**Windows (Alternatif dengan Git Bash):**
```bash
# Install Git Bash terlebih dahulu: https://git-scm.com/downloads
# Kemudian gunakan command seperti Linux/Mac
bash <(curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/install.sh)
```

**Langkah 2**: Restart terminal atau jalankan:

```bash
source ~/.bashrc  # atau source ~/.zshrc
```

**Langkah 3**: Jalankan Dockerin

```bash
dockerin start
```

**Langkah 4**: Ikuti panduan interaktif, jawab pertanyaan yang muncul

**Langkah 5**: Setup Laravel project

```bash
cd nama-project-anda
docker-compose up -d
docker-compose exec php composer install
docker-compose exec php php artisan key:generate
docker-compose exec php php artisan migrate
```

**Selesai!** 🎉 Aplikasi Laravel Anda sudah berjalan di Docker.

---

### Opsi Instalasi Lainnya

#### Opsi 1: GitHub Pages (Paling Pendek)

```bash
# Run menu langsung dari GitHub Pages
curl -sL https://irvandoda.github.io/dockerin/start | bash
```

#### Opsi 2: Shortcut Scripts

```bash
# Run menu
curl -sL https://raw.githubusercontent.com/irvandoda/dockerin/main/start.sh | bash

# Run dev-tools
curl -sL https://raw.githubusercontent.com/irvandoda/dockerin/main/dev-tools.sh | bash

# Run tutorial
curl -sL https://raw.githubusercontent.com/irvandoda/dockerin/main/tutorial.sh | bash
```

#### Opsi 3: Remote Execution (Tanpa Install)

**Linux/Mac/Git Bash:**
```bash
# Run menu.sh langsung dari GitHub
bash <(curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/bootstrap.sh) menu

# Run dev-tools.sh
bash <(curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/bootstrap.sh) dev-tools logs

# Run tutorial.sh
bash <(curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/bootstrap.sh) tutorial
```

**Windows PowerShell:**
```powershell
# Run menu menggunakan PowerShell
powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/irvandoda/dockerin/main/bootstrap.ps1' -OutFile bootstrap.ps1; .\bootstrap.ps1 menu"

# Atau lebih sederhana (jika sudah download bootstrap.ps1)
.\bootstrap.ps1 menu
```

**Windows CMD:**
```cmd
# Run menu menggunakan CMD (requires Git Bash or WSL)
bootstrap.bat menu

# Atau langsung dengan curl dan bash
curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/menu.sh | bash
```

**Alternatif untuk Windows (Recommended):**
```bash
# Install Git Bash terlebih dahulu: https://git-scm.com/downloads
# Kemudian gunakan command seperti Linux/Mac
bash <(curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/bootstrap.sh) menu
```

#### Opsi 4: Clone Repository

```bash
# Clone repository
git clone https://github.com/irvandoda/dockerin.git
cd dockerin

# Make executable
chmod +x *.sh
chmod +x generators/*.sh
chmod +x utils/*.sh

# Run
./menu.sh
```

---

## 📋 Fitur Lengkap

### 🎯 Core Features

| Fitur | Deskripsi |
|-------|-----------|
| **Interactive CLI** | Menu interaktif dengan color output dan validasi input |
| **Port Management** | Auto-detection port yang sudah digunakan, generate port alternatif |
| **Database Support** | MySQL dan PostgreSQL dengan konfigurasi otomatis |
| **Redis Integration** | Support Redis untuk caching dan queue |
| **Nginx Configuration** | Konfigurasi Nginx lengkap dengan SSL, Cache, Rate Limiting |
| **Mail Catcher** | MailHog/Mailpit untuk testing email di development |
| **Xdebug Support** | Setup Xdebug untuk PHP debugging dengan IDE integration |
| **Queue Worker** | Laravel queue worker dengan Supervisor |
| **Database Admin** | phpMyAdmin atau Adminer untuk database management |

### 🔧 Development Tools

| Tool | Deskripsi |
|------|-----------|
| **Log Viewer** | Real-time log viewing untuk semua services dengan color coding |
| **Health Check** | Monitor status semua services dan auto-restart jika down |
| **Shell Access** | Quick access ke container shell untuk debugging |
| **Cache Management** | Clear Laravel, Redis, Nginx cache dengan satu command |
| **Database Backup** | Automated database backup dengan timestamp |
| **Database Restore** | Restore database dari backup file |
| **Hot Reload** | Auto-reload container saat file berubah |

### 📁 Project Management

| Fitur | Deskripsi |
|-------|-----------|
| **Multiple Projects** | Manage multiple Laravel projects dalam satu sistem |
| **Project Switching** | Quick switch antar projects |
| **Config Backup** | Backup dan restore project configuration |
| **Export/Import** | Export config untuk sharing atau backup |
| **Preset Templates** | Preset untuk API, SPA, Full-stack, Microservice |

### 🎨 Preset Templates

- **API Preset**: Laravel API-only setup (tanpa frontend assets)
- **SPA Preset**: Laravel + SPA frontend (Vue/React) dengan hot reload
- **Full-stack Preset**: Complete Laravel setup dengan semua fitur
- **Microservice Preset**: Multiple Laravel services setup

---

## 📚 Dokumentasi Lengkap

### 1. Generate Docker Compose

Jalankan menu interaktif:

```bash
dockerin start
# atau
./menu.sh
```

**Pertanyaan yang akan ditanyakan:**

1. **Nama Project**: Nama untuk project Laravel Anda
2. **Versi Laravel**: Latest, 11.x, 10.x, atau 9.x
3. **Versi PHP**: 8.4, 8.3, 8.2, 8.1, atau 8.0
4. **Database Type**: MySQL atau PostgreSQL
5. **Database Credentials**: Username, password, database name, port
6. **Redis**: Enable atau tidak
7. **Nginx Configuration**: 
   - HTTP port (default: 80)
   - HTTPS port (default: 443)
   - SSL support
   - Cache configuration
   - Rate limiting
8. **Additional Features**:
   - Mail Catcher (MailHog/Mailpit)
   - Xdebug untuk debugging
   - Queue Worker
   - Database Admin Tool (phpMyAdmin/Adminer)
   - Hot Reload
9. **Preset Template**: API, SPA, Full-stack, atau Custom

Setelah semua pertanyaan dijawab, Dockerin akan menampilkan **summary** konfigurasi sebelum generate.

### 2. Setup Laravel Project

Setelah generate docker-compose.yml, setup Laravel project:

```bash
# Masuk ke directory project
cd nama-project-anda

# Start containers
docker-compose up -d

# Install Composer dependencies
docker-compose exec php composer install

# Generate application key
docker-compose exec php php artisan key:generate

# Run migrations
docker-compose exec php php artisan migrate

# (Optional) Run seeders
docker-compose exec php php artisan db:seed
```

### 3. Development Tools

#### View Logs

```bash
# View semua logs
dockerin dev-tools logs

# View logs service tertentu
dockerin dev-tools logs php
dockerin dev-tools logs nginx
dockerin dev-tools logs db
dockerin dev-tools logs redis
```

#### Health Check

```bash
# Check health semua services
dockerin dev-tools health
```

Output akan menampilkan:
- Status container (running/stopped)
- PHP service health
- Nginx service health
- Database service health

#### Shell Access

```bash
# Access PHP container
dockerin dev-tools shell php

# Access database container
dockerin dev-tools shell db

# Access Nginx container
dockerin dev-tools shell nginx
```

#### Restart Services

```bash
# Restart semua services
dockerin dev-tools restart

# Restart service tertentu
dockerin dev-tools restart php
dockerin dev-tools restart nginx
```

#### Clear Cache

```bash
# Clear semua cache (Laravel, Redis, Nginx)
dockerin dev-tools clear-cache
```

Akan membersihkan:
- Laravel cache
- Laravel config cache
- Laravel route cache
- Laravel view cache
- Redis cache
- Nginx cache

#### Status Monitoring

```bash
# Show container status dan resource usage
dockerin dev-tools status
```

### 4. Database Tools

#### Backup Database

```bash
# Backup database
dockerin db-tools backup
```

Backup akan disimpan di `backups/db_backup_YYYYMMDD_HHMMSS.sql.gz`

#### Restore Database

```bash
# Restore dari backup
dockerin db-tools restore backups/db_backup_20240101_120000.sql

# Restore dari compressed backup
dockerin db-tools restore backups/db_backup_20240101_120000.sql.gz
```

#### Run Migrations

```bash
# Run Laravel migrations
dockerin db-tools migrate
```

#### Run Seeders

```bash
# Run Laravel seeders
dockerin db-tools seed
```

#### Database Shell

```bash
# Open database shell
dockerin db-tools shell
```

Untuk MySQL: akan membuka `mysql` CLI
Untuk PostgreSQL: akan membuka `psql` CLI

#### Test Connection

```bash
# Test database connection
dockerin db-tools test
```

### 5. Tutorial Interaktif

Jalankan tutorial step-by-step:

```bash
dockerin tutorial
```

**Tutorial mencakup:**

1. **Prerequisites Check**: Cek Docker, Docker Compose, Git
2. **Generate docker-compose.yml**: Panduan generate konfigurasi
3. **Setup Laravel Project**: Create atau use existing project
4. **Configure Environment**: Setup .env file
5. **Start Containers**: Build dan start Docker containers
6. **Install Dependencies**: Install Composer dependencies
7. **Laravel Setup**: Generate key, migrate, seed
8. **Testing**: Test aplikasi di browser
9. **Troubleshooting**: Common issues dan solusinya

### 6. Project Management

#### List Projects

```bash
# List semua registered projects
dockerin project-manager list
```

#### Register Project

```bash
# Register project saat ini
dockerin project-manager register my-project

# Register project dengan path tertentu
dockerin project-manager register my-project /path/to/project
```

#### Switch Project

```bash
# Switch ke project lain
dockerin project-manager switch my-project
```

#### Backup Project Config

```bash
# Backup project configuration
dockerin project-manager backup my-project

# Backup dengan custom filename
dockerin project-manager backup my-project backups/my-backup.tar.gz
```

#### Delete Project from Registry

```bash
# Remove project dari registry (tidak delete files)
dockerin project-manager delete my-project
```

---

## 📁 Struktur File yang Dihasilkan

Setelah generate, Anda akan mendapatkan struktur file berikut:

```
nama-project-anda/
├── docker-compose.yml          # Docker Compose configuration
├── Dockerfile                  # PHP-FPM Dockerfile
├── php.ini                     # PHP configuration
├── nginx.conf                  # Nginx configuration
├── .env                        # Laravel environment file
├── PORT_MAPPING.txt            # Port mapping reference
├── PROJECT_CONFIG.json          # Project configuration backup
└── ssl/                        # SSL certificates (jika SSL enabled)
    ├── cert.pem
    └── key.pem
```

### Penjelasan File

- **docker-compose.yml**: Konfigurasi utama untuk semua services (PHP, Nginx, Database, Redis, dll)
- **Dockerfile**: Konfigurasi untuk PHP-FPM container dengan extensions yang diperlukan
- **php.ini**: Konfigurasi PHP (memory limit, upload size, timezone, Xdebug jika enabled)
- **nginx.conf**: Konfigurasi Nginx untuk Laravel dengan SSL, cache, rate limiting
- **.env**: Environment variables untuk Laravel (database, Redis, Mail, dll)
- **PORT_MAPPING.txt**: Daftar semua port yang digunakan untuk referensi
- **PROJECT_CONFIG.json**: Backup konfigurasi project untuk restore atau sharing

---

## 🎯 Contoh Penggunaan

### Contoh 1: Setup Laravel API

```bash
# 1. Generate docker-compose.yml
dockerin start

# Pilih konfigurasi:
# - Project name: my-api
# - Laravel version: Latest
# - PHP version: 8.3
# - Database: MySQL
# - Redis: Yes
# - Preset: API

# 2. Setup project
cd my-api
docker-compose up -d

# 3. Install dependencies
docker-compose exec php composer install

# 4. Setup Laravel
docker-compose exec php php artisan key:generate
docker-compose exec php php artisan migrate

# 5. Test API
curl http://localhost:80/api
```

### Contoh 2: Development dengan Xdebug

```bash
# 1. Generate dengan Xdebug enabled
dockerin start
# Pilih: Enable Xdebug: Yes

# 2. Setup Xdebug di IDE

# VS Code:
# - Install extension: PHP Debug
# - Create .vscode/launch.json:
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/var/www/html": "${workspaceFolder}"
      }
    }
  ]
}

# PHPStorm:
# - Settings > PHP > Debug
# - Xdebug port: 9003
# - Path mappings: /var/www/html -> project folder

# 3. Start debugging
# Set breakpoint dan start debug session
```

### Contoh 3: Database Backup & Restore

```bash
# Backup sebelum deploy
dockerin db-tools backup
# Output: backups/db_backup_20240101_120000.sql.gz

# Restore jika ada masalah
dockerin db-tools restore backups/db_backup_20240101_120000.sql.gz
```

### Contoh 4: Multiple Projects

```bash
# Project 1: API
dockerin start
# Project name: api-project
cd api-project
docker-compose up -d

# Register project
dockerin project-manager register api-project

# Project 2: SPA
dockerin start
# Project name: spa-project
cd spa-project
docker-compose up -d

# Register project
dockerin project-manager register spa-project

# List projects
dockerin project-manager list

# Switch antar projects
dockerin project-manager switch api-project
dockerin project-manager switch spa-project
```

### Contoh 5: Development Workflow

```bash
# 1. Start development
docker-compose up -d

# 2. View logs
dockerin dev-tools logs -f

# 3. Make changes to code
# ... edit files ...

# 4. Clear cache jika perlu
dockerin dev-tools clear-cache

# 5. Test changes
curl http://localhost:80

# 6. Backup database sebelum testing
dockerin db-tools backup

# 7. Run migrations
dockerin db-tools migrate

# 8. Check health
dockerin dev-tools health
```

---

## 🪟 Windows Users

### Instalasi Git Bash (Recommended)

Untuk pengalaman terbaik di Windows, install Git Bash:

1. Download dari: https://git-scm.com/downloads
2. Install dengan default settings
3. Gunakan Git Bash terminal
4. Jalankan command seperti di Linux/Mac

### Alternatif: PowerShell

Jika menggunakan PowerShell, gunakan script PowerShell:

```powershell
# Download dan run bootstrap.ps1
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/irvandoda/dockerin/main/bootstrap.ps1' -OutFile bootstrap.ps1
.\bootstrap.ps1 menu
```

### Alternatif: WSL2

Install WSL2 untuk pengalaman Linux di Windows:

```powershell
# Install WSL2
wsl --install

# Setelah install, gunakan WSL terminal
wsl

# Kemudian jalankan command seperti Linux
bash <(curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/bootstrap.sh) menu
```

### Error: `<` operator is reserved

Jika mendapat error ini di PowerShell:
```
The '<' operator is reserved for future use.
```

**Solusi:**
1. Gunakan Git Bash (recommended)
2. Atau gunakan PowerShell script: `.\bootstrap.ps1 menu`
3. Atau gunakan command alternatif:
   ```powershell
   curl -s https://raw.githubusercontent.com/irvandoda/dockerin/main/menu.sh | bash
   ```

---

## 🔍 Troubleshooting

### Port Already in Use

**Masalah**: Port yang dipilih sudah digunakan oleh aplikasi lain.

**Solusi**:
```bash
# Dockerin akan otomatis detect dan suggest port alternatif
# Atau check manual:
dockerin dev-tools status

# Edit docker-compose.yml dan PORT_MAPPING.txt jika perlu
```

### Database Connection Error

**Masalah**: Laravel tidak bisa connect ke database.

**Solusi**:
```bash
# 1. Test database connection
dockerin db-tools test

# 2. Check database container
dockerin dev-tools logs db

# 3. Check .env file
cat .env | grep DB_

# 4. Restart database container
dockerin dev-tools restart db
```

### Permission Errors

**Masalah**: Permission denied saat write ke storage atau cache.

**Solusi**:
```bash
# Fix Laravel storage permissions
docker-compose exec php chown -R www-data:www-data /var/www/html/storage
docker-compose exec php chmod -R 775 /var/www/html/storage
docker-compose exec php chmod -R 775 /var/www/html/bootstrap/cache
```

### Container Won't Start

**Masalah**: Container tidak bisa start atau langsung exit.

**Solusi**:
```bash
# 1. Check logs
dockerin dev-tools logs

# 2. Check container status
docker-compose ps

# 3. Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 4. Check Docker resources
docker stats
```

### Xdebug Not Working

**Masalah**: Xdebug tidak connect ke IDE.

**Solusi**:
```bash
# 1. Check Xdebug enabled
docker-compose exec php php -m | grep xdebug

# 2. Check Xdebug config
docker-compose exec php php -i | grep xdebug

# 3. Check port 9003
netstat -an | grep 9003

# 4. Restart PHP container
dockerin dev-tools restart php
```

### Nginx 502 Bad Gateway

**Masalah**: Nginx tidak bisa connect ke PHP-FPM.

**Solusi**:
```bash
# 1. Check PHP container running
docker-compose ps php

# 2. Check PHP-FPM listening
docker-compose exec php netstat -tuln | grep 9000

# 3. Restart both services
dockerin dev-tools restart php
dockerin dev-tools restart nginx
```

### Redis Connection Error

**Masalah**: Laravel tidak bisa connect ke Redis.

**Solusi**:
```bash
# 1. Check Redis container
docker-compose ps redis

# 2. Test Redis connection
docker-compose exec redis redis-cli ping

# 3. Check .env file
cat .env | grep REDIS

# 4. Restart Redis
dockerin dev-tools restart redis
```

---

## 🛠️ Requirements

### Minimum Requirements

- **Docker**: Version 20.10 atau lebih baru
- **Docker Compose**: Version 2.0 atau lebih baru
- **Bash Shell**: Bash 4.0+ (Linux, Mac, atau Git Bash/WSL untuk Windows)
- **curl atau wget**: Untuk remote execution

### Recommended

- **Git**: Untuk clone repository (optional)
- **Composer**: Untuk install Laravel (atau gunakan Docker)
- **4GB RAM**: Minimum untuk run containers
- **10GB Disk Space**: Untuk Docker images dan volumes

### Platform Support

- ✅ **Linux**: Full support (native bash)
- ✅ **macOS**: Full support (native bash)
- ✅ **Windows**: 
  - ✅ **Git Bash**: Full support (recommended)
  - ✅ **WSL2**: Full support
  - ✅ **PowerShell**: Support via `bootstrap.ps1`
  - ✅ **CMD**: Support via `bootstrap.bat` (requires Git Bash/WSL)

---

## 📖 Advanced Usage

### Custom Dockerfile

Edit `Dockerfile` untuk menambahkan PHP extensions atau konfigurasi custom:

```dockerfile
FROM php:8.3-fpm

# Install additional extensions
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# Install custom packages
RUN apt-get update && apt-get install -y \
    your-package-here \
    && rm -rf /var/lib/apt/lists/*

# Custom configuration
COPY custom-php.ini /usr/local/etc/php/conf.d/
```

### Custom Nginx Configuration

Edit `nginx.conf` untuk konfigurasi custom:

```nginx
server {
    listen 80;
    server_name your-domain.local;
    
    # Custom configuration
    location /api {
        # API-specific config
    }
}
```

### Environment Variables

Edit `.env` untuk environment variables custom:

```env
APP_NAME="My Laravel App"
APP_ENV=local
APP_DEBUG=true

# Database
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=root

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
```

---

## 🤝 Contributing

Kontribusi sangat diterima! Berikut cara berkontribusi:

1. **Fork** repository ini
2. **Create** branch untuk fitur baru (`git checkout -b feature/AmazingFeature`)
3. **Commit** perubahan (`git commit -m 'Add some AmazingFeature'`)
4. **Push** ke branch (`git push origin feature/AmazingFeature`)
5. **Open** Pull Request

### Development Setup

```bash
# Clone repository
git clone https://github.com/irvandoda/dockerin.git
cd dockerin

# Create development branch
git checkout -b dev

# Make changes
# ... edit files ...

# Test changes
./menu.sh

# Commit changes
git add .
git commit -m "Description of changes"

# Push to dev branch
git push origin dev
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Irvando Demas Arifiandani**

- **GitHub**: [@irvandoda](https://github.com/irvandoda)
- **Website**: [irvandoda.my.id](https://irvandoda.my.id)
- **WhatsApp**: [+62 857 4747 6308](https://wa.me/6285747476308)

---

## 🙏 Acknowledgments

- **Laravel Community** - Framework yang luar biasa
- **Docker Community** - Containerization platform
- **All Contributors** - Semua yang telah berkontribusi
- **Open Source Community** - Untuk inspirasi dan tools yang digunakan

---

## 📞 Support

Jika Anda memiliki pertanyaan atau butuh bantuan:

- 📧 **Email**: Kontak melalui [Website](https://irvandoda.my.id)
- 💬 **WhatsApp**: [+62 857 4747 6308](https://wa.me/6285747476308)
- 🐛 **Issues**: [GitHub Issues](https://github.com/irvandoda/dockerin/issues)
- 📖 **Documentation**: Lihat [Wiki](https://github.com/irvandoda/dockerin/wiki)

---

<div align="center">

**Made with ❤️ by [Irvando Demas Arifiandani](https://irvandoda.my.id) for Laravel Developers**

⭐ Star this repo if you find it helpful!

[⬆ Back to Top](#-dockerin---interactive-docker-cli-for-laravel)

</div>
