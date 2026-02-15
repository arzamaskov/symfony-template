# Symfony Template

Docker-окружение для Symfony 7 LTS с PHP 8.4, PostgreSQL и Nginx.

## Стек

- PHP 8.4 (FPM, Alpine)
- Symfony 7.4 LTS
- PostgreSQL 18
- Nginx

## Быстрый старт

```bash
# Скопировать dev-конфигурацию
cp docker-compose.override.yml.dist docker-compose.override.yml

# Собрать образы и запустить
make build
make up

# Установить зависимости
make composer args="install"
```

Приложение будет доступно по адресу: http://localhost:8080

## Требования

- Docker >= 24.0
- Docker Compose >= 2.20
- Make

## Makefile-команды

| Команда | Описание |
|---------|----------|
| `make help` | Список всех команд |
| `make build` | Сборка Docker-образов |
| `make up` | Запуск контейнеров |
| `make down` | Остановка контейнеров |
| `make restart` | Перезапуск |
| `make logs` | Логи (follow mode) |
| `make ps` | Статус контейнеров |
| `make shell` | Shell в php-fpm контейнере |
| `make composer args="..."` | Запуск Composer |
| `make sf args="..."` | Запуск Symfony Console |
| `make db` | psql в postgres контейнере |
| `make cache-clear` | Очистка кэша Symfony |

## Docker-архитектура

```
docker/
├── nginx/
│   └── default.conf
└── php-fpm/
    ├── Dockerfile          # multi-stage: base → prod / dev
    └── conf.d/
        ├── php.dev.ini     # Xdebug, display_errors
        └── php.prod.ini    # OPcache, JIT
```

- `docker-compose.yml` — production-конфигурация
- `docker-compose.override.yml.dist` — шаблон dev-конфигурации

### Dockerfile стейджи

- **base** — общий образ: PHP-расширения (pdo_pgsql, intl, opcache, zip, apcu), Composer
- **prod** — копирует код, `composer install --no-dev`, агрессивный OPcache + JIT
- **dev** — Xdebug, display_errors, код монтируется через volume

## Xdebug (dev)

Xdebug настроен в режиме `trigger`:

- Порт: `9003`
- IDE key: `PHPSTORM`
- Активация: через расширение браузера или `XDEBUG_TRIGGER=1`
