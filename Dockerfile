FROM php:8.2-fpm

ENV DIR_OPENCART='/var/www/html/opencart/'
ENV DIR_STORAGE='/storage/'
ENV DIR_IMAGE=${DIR_OPENCART}'image/'

RUN apt-get update && apt-get install -y \
  nginx unzip curl vim supervisor \
  libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd zip mysqli \
  && apt-get clean

COPY ../upload/ ${DIR_OPENCART}
COPY ../supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ../nginx/default.conf /etc/nginx/sites-available/default

RUN mkdir -p ${DIR_STORAGE} \
  && cp -r ${DIR_OPENCART}/system/storage/* ${DIR_STORAGE} \
  && chown -R www-data:www-data ${DIR_STORAGE} ${DIR_IMAGE}

CMD ["/usr/bin/supervisord"]

