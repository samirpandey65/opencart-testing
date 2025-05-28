FROM php:8.2.11-apache

ARG DOWNLOAD_URL
ARG FOLDER

ENV DIR_OPENCART='/var/www/html/'
ENV DIR_STORAGE='/storage/'
ENV DIR_CACHE=${DIR_STORAGE}'cache/'
ENV DIR_DOWNLOAD=${DIR_STORAGE}'download/'
ENV DIR_LOGS=${DIR_STORAGE}'logs/'
ENV DIR_SESSION=${DIR_STORAGE}'session/'
ENV DIR_UPLOAD=${DIR_STORAGE}'upload/'
ENV DIR_IMAGE=${DIR_OPENCART}'image/'

# Install dependencies, apt-utils to fix debconf warning, unzip, vim, and PHP extensions gd, zip, mysqli
RUN apt-get update && apt-get install -y \
    apt-utils \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    unzip \
    vim \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd zip mysqli \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /storage && mkdir /opencart

# Download OpenCart zip
RUN if [ -z "$DOWNLOAD_URL" ]; then \
      curl -Lo /tmp/opencart.zip $(sh -c 'curl -s https://api.github.com/repos/opencart/opencart/releases/latest | grep "browser_download_url" | cut -d : -f 2,3 | tr -d \"'); \
    else \
      curl -Lo /tmp/opencart.zip ${DOWNLOAD_URL}; \
    fi

RUN unzip /tmp/opencart.zip -d /tmp/opencart;

# Move upload folder from extracted zip to web root
RUN mv /tmp/opencart/$(if [ -n "$FOLDER" ]; then echo $FOLDER; else unzip -l /tmp/opencart.zip | awk '{print $4}' | grep -E 'opencart-[a-z0-9.]+/upload/$'; fi)* ${DIR_OPENCART}

RUN rm -rf /tmp/opencart.zip /tmp/opencart ${DIR_OPENCART}install

RUN mv ${DIR_OPENCART}system/storage/* /storage

COPY configs ${DIR_OPENCART}
COPY php.ini ${PHP_INI_DIR}

RUN a2enmod rewrite

# Set permissions
RUN chown -R www-data:www-data ${DIR_STORAGE} ${DIR_IMAGE} \
  && chmod -R 555 ${DIR_OPENCART} \
  && chmod -R 666 ${DIR_STORAGE} \
  && chmod 555 ${DIR_STORAGE} \
  && chmod -R 555 ${DIR_STORAGE}vendor \
  && chmod 755 ${DIR_LOGS} \
  && chmod -R 644 ${DIR_LOGS}* \
  && chmod -R 744 ${DIR_IMAGE} \
  && chmod -R 755 ${DIR_CACHE} \
  && chmod -R 666 ${DIR_DOWNLOAD} \
  && chmod -R 666 ${DIR_SESSION} \
  && chmod -R 666 ${DIR_UPLOAD}

CMD ["apache2-foreground"]

