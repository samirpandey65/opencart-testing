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

# Copy application code
COPY upload/ ${DIR_OPENCART}
COPY nginx/default.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create and populate the storage folder (only if it exists)
RUN mkdir -p ${DIR_STORAGE} \
  && if [ -d "${DIR_OPENCART}/system/storage" ]; then \
       cp -r ${DIR_OPENCART}/system/storage/* ${DIR_STORAGE} || echo "No files to copy"; \
     else \
       echo "Warning: system/storage not found"; \
     fi \
  && chown -R www-data:www-data ${DIR_STORAGE} ${DIR_IMAGE}

CMD ["/usr/bin/supervisord"]

