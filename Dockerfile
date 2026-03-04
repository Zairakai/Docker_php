# ================
# BUILD ARGUMENTS - VERSIONS
# ================
# PECL extensions
ARG REDIS_VERSION=6.1.0
ARG XDEBUG_VERSION=3.4.0
ARG PCOV_VERSION=1.0.11

# Build metadata
ARG IMAGE_VERSION=unknown
ARG GIT_COMMIT=unknown
ARG BUILD_DATE=unknown

# ================
# STAGE 0: BASE
# ================
FROM php:8.3-fpm-alpine AS base

LABEL maintainer="Stanislas Poisson <stanislas.p@the-white-rabbits.com>" \
    org.opencontainers.image.source="https://gitlab.com/zairakai/dockers/php" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.description="PHP 8.3 FPM Alpine base image"

ARG REDIS_VERSION
ARG IMAGE_VERSION
ARG GIT_COMMIT
ARG BUILD_DATE

# Inject metadata as environment variables
ENV BUILD_STAGE=base \
    IMAGE_VERSION=${IMAGE_VERSION} \
    GIT_COMMIT=${GIT_COMMIT} \
    BUILD_DATE=${BUILD_DATE} \
    REDIS_VERSION=${REDIS_VERSION}

EXPOSE 9000

RUN addgroup -g 1000 www \
    && adduser -u 1000 -G www -s /bin/sh -D www \
    && install -d -m 0755 -o www -g www \
    /var/lib/php/sessions \
    /var/log/php \
    /tmp/opcache \
    /var/run/php \
    /var/www/html

WORKDIR /var/www/html

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY --chown=root:root scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=root:root scripts/healthcheck.sh /usr/local/bin/healthcheck.sh

RUN chmod +x /usr/local/bin/*.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    bash \
    fcgi \
    freetype \
    libjpeg-turbo \
    libpng \
    libzip \
    icu \
    oniguruma \
    postgresql-libs \
    && apk add --no-cache --virtual .build-deps \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    postgresql-dev \
    linux-headers \
    $PHPIZE_DEPS \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
    gd \
    zip \
    intl \
    mbstring \
    pdo_mysql \
    pdo_pgsql \
    bcmath \
    opcache \
    pcntl \
    sockets \
    && pecl install redis-${REDIS_VERSION} \
    && docker-php-ext-enable redis \
    && apk del .build-deps \
    && rm -rf /tmp/pear /var/cache/apk/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]

# ================
# STAGE 1: PRODUCTION
# ================
FROM base AS prod

LABEL stage="prod" \
    description="Production-ready PHP 8.3 FPM"

ENV BUILD_STAGE=prod

COPY --chown=root:root config/prod/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY --chown=root:root config/prod/fpm.conf /usr/local/etc/php-fpm.d/zz-custom.conf
COPY --chown=root:root config/prod/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

USER www

# ================
# STAGE 2: DEVELOPMENT
# ================
FROM base AS dev

LABEL stage="dev" \
    description="Development PHP 8.3 with Xdebug"

ARG XDEBUG_VERSION

ENV BUILD_STAGE=dev \
    XDEBUG_VERSION=${XDEBUG_VERSION} \
    COMPOSER_MEMORY_LIMIT=-1

USER root

RUN install -d -m 0755 -o www -g www /var/log/xdebug

COPY --chown=root:root config/dev/php.ini /usr/local/etc/php/conf.d/custom-dev.ini
COPY --chown=root:root config/dev/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Install dev tools and Xdebug
RUN apk add --no-cache \
    git \
    vim \
    curl \
    wget \
    unzip \
    mariadb-client \
    postgresql-client \
    && apk add --no-cache --virtual .xdebug-build-deps \
    linux-headers \
    $PHPIZE_DEPS \
    && pecl install xdebug-${XDEBUG_VERSION} \
    && docker-php-ext-enable xdebug \
    && apk del .xdebug-build-deps \
    && rm -rf /tmp/pear /var/cache/apk/*

USER www

# ================
# STAGE 3: TEST
# ================
FROM base AS test

LABEL stage="test" \
    description="Test PHP 8.3 with PCOV for coverage"

ARG PCOV_VERSION

ENV BUILD_STAGE=test \
    PCOV_VERSION=${PCOV_VERSION} \
    PCOV_ENABLED=1 \
    COMPOSER_MEMORY_LIMIT=-1

USER root

RUN install -d -m 0755 -o www -g www \
    /tmp/coverage \
    /tmp/test-results

COPY --chown=root:root config/test/php.ini /usr/local/etc/php/conf.d/custom-test.ini
COPY --chown=root:root config/test/pcov.ini /usr/local/etc/php/conf.d/pcov.ini

# Install PCOV
RUN apk add --no-cache git \
    && apk add --no-cache --virtual .pcov-build-deps \
    $PHPIZE_DEPS \
    linux-headers \
    && pecl install pcov-${PCOV_VERSION} \
    && docker-php-ext-enable pcov \
    && apk del .pcov-build-deps \
    && rm -rf /tmp/pear /var/cache/apk/*

USER www
