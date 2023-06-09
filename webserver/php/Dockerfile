FROM php:7.4-fpm
RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

WORKDIR /var/www/html

COPY selections.conf selections.conf
RUN apt-get install debconf-utils
RUN debconf-set-selections < selections.conf
#RUN dpkg-reconfigure keyboard-configuration -f noninteractive
RUN apt install -y libicu-dev
RUN apt install -y lilypond imagemagick ghostscript fluidsynth firejail lame

RUN docker-php-ext-configure intl
RUN docker-php-ext-install gd pdo pdo_mysql mysqli intl
RUN docker-php-ext-enable pdo_mysql intl
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add UID '1000' to www-data
RUN usermod -u 1000 www-data
# Copy existing application directory permissions
# COPY --chown=www-data:www-data . /var/www/html
# Change current user to www
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
