FROM php:8.2-apache
RUN docker-php-ext-install mysqli pdo pdo_mysql
# Enable Apache modules
RUN a2enmod rewrite

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
# RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

RUN apt-get update \
     && docker-php-ext-install mysqli pdo pdo_mysql  exif pcntl bcmath gd \
     && docker-php-ext-enable pdo_mysql

ENV COMPOSER_ALLOW_SUPERUSER=1

# RUN composer_install.sh
# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Copy existing application directory contents
COPY . .

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html

# Install project dependencies
RUN composer install && composer dump-autoload