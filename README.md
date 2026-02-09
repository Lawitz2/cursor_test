# Интернет-магазин «Доктор Орлинская»

Backend для интернет-магазина БАД, инфопродуктов и услуг.

## Технологии

- Go 1.21+
- PostgreSQL
- Gin (web framework)
- sqlc (type-safe SQL)
- goose (migrations)
- Redis (для OTP и кеша)

## Структура проекта

```
cmd/api/              - точка входа приложения
internal/
  config/            - конфигурация
  db/                - работа с БД
  domain/            - бизнес-логика по доменам
  repository/        - репозитории (адаптеры над sqlc)
  http/              - HTTP handlers, router, middleware
  templates/         - HTML шаблоны
  static/            - статические файлы (CSS, JS)
  auth/              - аутентификация
  integration/       - интеграции с внешними сервисами
db/
  queries/           - SQL запросы для sqlc
  migrations/        - миграции goose (используется папка migrations/)
migrations/          - миграции goose
```

## Установка и запуск

1. Установить зависимости:
```bash
go mod download
```

2. Настроить `.env` файл (скопировать из `.env.example`)

3. Применить миграции:
```bash
goose -dir migrations postgres "postgres://user:password@localhost:5432/doctor_orlinskaya?sslmode=disable" up
```

4. Запустить приложение:
```bash
go run cmd/api/main.go
```

## Разработка

- Миграции: `goose -dir migrations postgres <DSN> up/down`
- Генерация sqlc кода: `sqlc generate`
- Запуск: `go run cmd/api/main.go`
