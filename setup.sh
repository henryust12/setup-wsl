#!/bin/bash

# =======================
# Script Setup Server
# =======================

# =======================
# Fungsi: Deteksi Lingkungan WSL
# =======================
is_wsl() {
    grep -qi "microsoft" /proc/version
}

# Fungsi untuk mencetak pesan dengan warna
print_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
print_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
print_warning() { echo -e "\033[1;33m[WARNING]\033[0m $1"; }
print_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# =======================
# Update dan Upgrade Sistem
# =======================
print_info "Updating and upgrading system packages..."
sudo apt-get update && sudo apt-get upgrade -y
print_success "System packages updated and upgraded."

# =======================
# Instalasi Paket Dasar
# =======================
print_info "Installing essential packages (git, apache2, nano, vim, neofetch)..."
sudo apt-get install -y git apache2 nano vim neofetch
print_success "Essential packages installed."

# =======================
# Verifikasi Instalasi Paket
# =======================
print_info "Verifying installations..."
git --version && print_success "Git installed."
apache2 -v && print_success "Apache installed."

# =======================
# Menambahkan PPA PHP 8.2 dan Update Package List
# =======================
print_info "Adding PPA for PHP 8.2 and updating package list..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update
print_success "PPA added and package list updated."

# =======================
# Instalasi PHP 8.2 dan Ekstensi
# =======================
print_info "Installing PHP 8.2 and common extensions..."
sudo apt-get install -y \
  php8.2 php8.2-cli php8.2-common php8.2-opcache php8.2-readline \
  php8.2-bcmath php8.2-curl php8.2-gd php8.2-mbstring php8.2-mysql \
  php8.2-xml php8.2-zip php8.2-sqlite3
print_success "PHP 8.2 and extensions installed."

# =======================
# Restart Apache Berdasarkan Lingkungan
# =======================
print_info "Restarting Apache server..."
if is_wsl; then
    print_info "Detected WSL environment. Using 'service' command to restart Apache."
    sudo service apache2 restart && print_success "Apache restarted (WSL)."
else
    print_info "Detected Linux server environment. Using 'systemctl' command to restart Apache."
    sudo systemctl restart apache2 && print_success "Apache restarted (Linux server)."
fi

# =======================
# Menambahkan User ke Grup www-data
# =======================
print_info "Adding user $USER to www-data group..."
sudo usermod -aG www-data "$USER"
print_success "User $USER added to www-data group."

# =======================
# Mengatur Izin untuk /var/www/html
# =======================
print_info "Setting permissions for /var/www/html..."
sudo chown -R "$USER":www-data /var/www/html
sudo chmod -R 775 /var/www/html
print_success "Permissions set for /var/www/html."

# =======================
# Membuat File phpinfo.php untuk Pengujian PHP
# =======================
print_info "Creating phpinfo.php for PHP test..."
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
print_success "phpinfo.php created."

# =======================
# Menguji File phpinfo.php
# =======================
print_info "Testing phpinfo.php..."
curl http://localhost/phpinfo.php || print_warning "Could not connect to http://localhost/phpinfo.php. Check Apache status."

# =======================
# Instalasi Composer
# =======================
print_info "Installing Composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "
if (hash_file('sha384', 'composer-setup.php') === '$HASH') {
    echo 'Installer verified';
} else {
    echo 'Installer corrupt';
    unlink('composer-setup.php');
    exit(1);
}
"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"
print_success "Composer installed."

# =======================
# Membuat Symlink untuk Composer
# =======================
print_info "Creating symlink for Composer..."
sudo ln -s /usr/local/bin/composer /usr/bin/composer
print_success "Symlink for Composer created."

# =======================
# Verifikasi Instalasi Composer
# =======================
print_info "Verifying Composer installation..."
composer -V && print_success "Composer verified."

# =======================
# Menambahkan Composer ke PATH Environment
# =======================
print_info "Adding Composer to PATH environment..."
export PATH="/usr/local/bin:$PATH"
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
print_success "Composer added to PATH."

# =======================
# Selesai
# =======================
print_success "Setup complete!"
