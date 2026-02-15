# syntax=docker/dockerfile:1

# ============================================
# Base stage: shared between prod and dev
# ============================================
FROM php:8.4-fpm-alpine AS base

RUN apk add --no-cache \
        icu-libs \
        libpq \
        libzip \
        linux-headers \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        icu-dev \
        libzip-dev \
        postgresql-dev \
    && docker-php-ext-install -j$(nproc) \
        intl \
        opcache \
        pdo_pgsql \
        zip \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .build-deps \
    && rm -rf /tmp/pear

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

RUN addgroup -g 1000 appuser \
    && adduser -u 1000 -G appuser -s /bin/sh -D appuser

# ============================================
# Production stage
# ============================================
FROM base AS prod

ENV APP_ENV=prod

COPY docker/php-fpm/conf.d/php.prod.ini $PHP_INI_DIR/conf.d/zz-prod.ini

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader

COPY . .

RUN composer dump-autoload --classmap-authoritative --no-dev \
    && composer run-script post-install-cmd --no-interaction || true \
    && chown -R appuser:appuser /app

USER appuser

# ============================================
# Development stage
# ============================================
FROM base AS dev

ENV APP_ENV=dev

RUN apk add --no-cache --virtual .xdebug-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .xdebug-deps \
    && rm -rf /tmp/pear

COPY docker/php-fpm/conf.d/php.dev.ini $PHP_INI_DIR/conf.d/zz-dev.ini

USER appuser
