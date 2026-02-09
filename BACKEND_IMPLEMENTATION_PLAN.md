# План реализации backend (MVP) — пошаговые задачи

Детальный план разработки backend для интернет-магазина «Доктор Орлинская» на Go + gin + sqlc + goose.

---

## Этап 1: Настройка инфраструктуры и базовой структуры проекта

### День 1: Инициализация проекта и настройка инструментов
- [x] Создать структуру папок проекта (`cmd/api`, `internal/...`, `db/...`)
- [x] Инициализировать `go.mod`
- [x] Установить зависимости: `gin`, `sqlc`, `goose`, драйвер Postgres (`pgx` или `lib/pq`)
- [ ] Настроить `sqlc.yaml` (указать схему из миграций и папку для queries)
- [ ] Создать базовый `cmd/api/main.go` с инициализацией gin и простым health-check endpoint
- [ ] Настроить `.env` файл для конфигурации (DB connection string, порты)

### День 2: Подключение к БД и применение миграций
- [ ] Создать `internal/config` пакет для загрузки конфигов из env
- [ ] Создать `internal/db/postgres.go` с функцией подключения к Postgres
- [ ] Настроить goose для применения миграций (команда или в коде)
- [ ] Применить все 3 миграции на локальной БД
- [ ] Проверить, что таблицы созданы корректно

### День 3: Настройка sqlc и первые queries
- [ ] Создать `db/queries/users.sql` с базовыми запросами (GetUserByID, CreateUser, GetUserByPhone, GetUserByEmail)
- [ ] Создать `db/queries/products.sql` с запросами (ListProducts, GetProductBySlug, GetProductByID)
- [ ] Запустить `sqlc generate` и проверить сгенерированный код
- [ ] Создать `internal/repository` пакет с интерфейсами и реализациями для users и products

---

## Этап 2: Базовый каталог товаров

### День 4: API для категорий
- [ ] Создать `db/queries/categories.sql` (ListCategories, GetCategoryBySlug, GetCategoryByID)
- [ ] Сгенерировать sqlc код
- [ ] Создать `internal/repository/categories.go`
- [ ] Создать `internal/http/handlers/catalog_handler.go` с GET `/api/v1/categories`
- [ ] Протестировать endpoint (через curl/Postman)

### День 5: API для списка товаров
- [ ] Расширить `db/queries/products.sql` для фильтрации по категориям, пагинации, сортировки
- [ ] Обновить sqlc код
- [ ] Расширить `internal/repository/products.go` с методами фильтрации
- [ ] Добавить в `catalog_handler.go` GET `/api/v1/products` с query параметрами (category, page, limit, sort)
- [ ] Протестировать endpoint с разными фильтрами

### День 6: API для карточки товара
- [ ] Добавить в `db/queries/products.sql` запросы для получения медиа и категорий товара
- [ ] Создать `db/queries/product_media.sql` (GetMediaByProductID)
- [ ] Обновить sqlc код
- [ ] Расширить `catalog_handler.go` GET `/api/v1/products/{slug}` с полной информацией о товаре
- [ ] Протестировать endpoint

### День 7: HTML-страницы каталога (простой фронт)
- [ ] Создать `internal/templates/public/base.tmpl` (базовый layout с header/footer)
- [ ] Создать `internal/templates/public/catalog.tmpl` (список товаров)
- [ ] Создать `internal/templates/public/product.tmpl` (карточка товара)
- [ ] Добавить в `catalog_handler.go` HTML endpoints: GET `/` (главная с категориями), GET `/catalog`, GET `/products/{slug}`
- [ ] Добавить простой CSS в `internal/static/css/main.css` для базовой стилизации

---

## Этап 3: Корзина

### День 8: Логика корзины (backend)
- [ ] Создать `db/queries/carts.sql` (CreateCart, GetCartByID, GetCartByUserID, GetCartByGuestToken, UpdateCartStatus)
- [ ] Создать `db/queries/cart_items.sql` (AddCartItem, UpdateCartItemQty, RemoveCartItem, GetCartItems)
- [ ] Обновить sqlc код
- [ ] Создать `internal/repository/carts.go`
- [ ] Создать `internal/domain/cart/service.go` с бизнес-логикой (создание корзины гостя, добавление товаров, слияние корзин при авторизации)

### День 9: API для корзины
- [ ] Создать `internal/http/handlers/cart_handler.go`:
  - POST `/api/v1/cart` (создать/получить корзину)
  - POST `/api/v1/cart/items` (добавить товар)
  - PATCH `/api/v1/cart/items/{id}` (изменить количество)
  - DELETE `/api/v1/cart/items/{id}` (удалить товар)
  - GET `/api/v1/cart` (получить корзину с товарами)
- [ ] Добавить middleware для работы с guest_token (cookie или header)
- [ ] Протестировать все endpoints

### День 10: HTML-страница корзины
- [ ] Создать `internal/templates/public/cart.tmpl`
- [ ] Добавить в `cart_handler.go` GET `/cart` (HTML)
- [ ] Добавить простой JS для обновления количества/удаления без перезагрузки (опционально, можно через формы)
- [ ] Протестировать UI

---

## Этап 4: Аутентификация

### День 11: OTP по телефону (backend)
- [ ] Создать `internal/auth/otp.go` с логикой генерации и проверки кодов
- [ ] Интегрировать с Redis для хранения кодов (TTL 5-10 минут)
- [ ] Добавить rate limiting для запросов OTP (через Redis)
- [ ] Создать `db/queries/users.sql` запросы для обновления телефона/email
- [ ] Обновить sqlc код

### День 12: API для аутентификации
- [ ] Создать `internal/http/handlers/auth_handler.go`:
  - POST `/api/v1/auth/otp/request` (отправить код на телефон)
  - POST `/api/v1/auth/otp/verify` (проверить код и создать/найти пользователя)
  - POST `/api/v1/auth/logout` (опционально)
- [ ] Создать JWT middleware для защиты приватных endpoints
- [ ] Протестировать endpoints

### День 13: HTML-страницы авторизации
- [ ] Создать `internal/templates/public/auth.tmpl` (форма ввода телефона и кода)
- [ ] Добавить в `auth_handler.go` GET `/login` и POST `/login` (HTML формы)
- [ ] Добавить простой JS для отправки кода и проверки
- [ ] Протестировать UI

---

## Этап 5: Оформление заказа

### День 14: Логика заказов (backend)
- [ ] Создать `db/queries/orders.sql` (CreateOrder, GetOrderByID, GetOrderByNumber, GetOrdersByUserID, UpdateOrderStatus)
- [ ] Создать `db/queries/order_items.sql` (CreateOrderItem, GetOrderItems)
- [ ] Обновить sqlc код
- [ ] Создать `internal/repository/orders.go`
- [ ] Создать `internal/domain/orders/service.go` с логикой создания заказа (валидация корзины, расчет суммы, создание order_items, обновление статуса корзины)

### День 15: API для заказов
- [ ] Создать `internal/http/handlers/orders_handler.go`:
  - POST `/api/v1/checkout` (создать заказ из корзины)
  - GET `/api/v1/orders/{orderNumber}` (получить заказ)
- [ ] Добавить валидацию данных заказа (адрес доставки, метод доставки)
- [ ] Протестировать endpoints

### День 16: HTML-страница оформления заказа
- [ ] Создать `internal/templates/public/checkout.tmpl` (форма с адресом и методом доставки)
- [ ] Добавить в `orders_handler.go` GET `/checkout` и POST `/checkout` (HTML)
- [ ] Добавить валидацию формы на фронте (базовую)
- [ ] Протестировать UI

---

## Этап 6: Интеграция с платежной системой

### День 17: Подготовка к интеграции с Т-Банк
- [ ] Изучить документацию API Т-Банк эквайринга
- [ ] Создать `internal/integration/tbank/client.go` с базовой структурой клиента
- [ ] Создать `db/queries/payment_attempts.sql` (CreatePaymentAttempt, UpdatePaymentAttempt, GetPaymentAttemptByID)
- [ ] Обновить sqlc код
- [ ] Создать `internal/repository/payments.go`

### День 18: Инициация платежа
- [ ] Реализовать в `tbank/client.go` метод создания платежа (инициация)
- [ ] Расширить `internal/domain/orders/service.go` для создания payment_attempt при создании заказа
- [ ] Создать `internal/http/handlers/payments_handler.go`:
  - POST `/api/v1/payments/{orderId}/init` (инициация платежа, возврат URL для редиректа)
- [ ] Протестировать создание платежа (можно с тестовыми данными Т-Банк)

### День 19: Webhook для платежей
- [ ] Реализовать в `tbank/client.go` валидацию webhook подписи (если требуется)
- [ ] Добавить в `payments_handler.go` POST `/api/v1/payments/webhook/tbank`
- [ ] Реализовать обработку webhook: обновление статуса payment_attempt и order
- [ ] Добавить идемпотентность (проверка, что webhook уже обработан)
- [ ] Протестировать webhook (можно через ngrok для локальной разработки)

### День 20: HTML-страницы оплаты
- [ ] Обновить `checkout.tmpl` для редиректа на оплату после создания заказа
- [ ] Создать `internal/templates/public/payment_success.tmpl` и `payment_failed.tmpl`
- [ ] Добавить в `payments_handler.go` GET `/payment/success` и `/payment/failed` (HTML)
- [ ] Протестировать полный флоу: корзина → заказ → оплата → webhook → страница успеха

---

## Этап 7: Личный кабинет (базовый)

### День 21: API для профиля пользователя
- [ ] Расширить `db/queries/users.sql` (UpdateUser, UpdateUserProfile)
- [ ] Обновить sqlc код
- [ ] Создать `internal/http/handlers/account_handler.go`:
  - GET `/api/v1/account/profile` (получить профиль)
  - PATCH `/api/v1/account/profile` (обновить профиль)
- [ ] Добавить JWT middleware на эти endpoints
- [ ] Протестировать endpoints

### День 22: API для истории заказов
- [ ] Расширить `db/queries/orders.sql` для получения заказов пользователя с фильтрацией
- [ ] Обновить sqlc код
- [ ] Добавить в `account_handler.go`:
  - GET `/api/v1/account/orders` (список заказов пользователя)
  - GET `/api/v1/account/orders/{orderNumber}` (детали заказа)
- [ ] Протестировать endpoints

### День 23: HTML-страницы личного кабинета
- [ ] Создать `internal/templates/account/base.tmpl` (layout с навигацией ЛК)
- [ ] Создать `internal/templates/account/profile.tmpl` (профиль)
- [ ] Создать `internal/templates/account/orders.tmpl` (список заказов)
- [ ] Создать `internal/templates/account/order_detail.tmpl` (детали заказа)
- [ ] Добавить в `account_handler.go` HTML endpoints
- [ ] Протестировать UI

---

## Этап 8: Базовый поиск

### День 24: Поиск по товарам (Postgres FTS)
- [ ] Добавить в `db/queries/products.sql` запрос поиска через `to_tsvector` / `to_tsquery`
- [ ] Обновить sqlc код
- [ ] Расширить `catalog_handler.go` GET `/api/v1/search?q=...` (поиск товаров)
- [ ] Добавить автодополнение (опционально, простой вариант через LIKE)
- [ ] Протестировать поиск

### День 25: HTML-страница результатов поиска
- [ ] Создать `internal/templates/public/search.tmpl`
- [ ] Добавить поисковую строку в header (базовый layout)
- [ ] Добавить в `catalog_handler.go` GET `/search` (HTML)
- [ ] Протестировать UI

---

## Этап 9: Базовая админ-панель

### День 26: Аутентификация админа
- [ ] Создать `internal/http/middleware/admin_auth.go` (проверка роли admin, можно hardcode для MVP)
- [ ] Создать `internal/http/handlers/admin_auth_handler.go` (простая форма входа для админа)
- [ ] Создать `internal/templates/admin/login.tmpl`
- [ ] Протестировать вход в админку

### День 27: Управление товарами (CRUD)
- [ ] Создать `db/queries/products.sql` для админки (CreateProduct, UpdateProduct, DeleteProduct)
- [ ] Обновить sqlc код
- [ ] Создать `internal/http/handlers/admin_products_handler.go`:
  - GET `/admin/products` (список)
  - GET `/admin/products/new` (форма создания)
  - POST `/admin/products` (создание)
  - GET `/admin/products/{id}/edit` (форма редактирования)
  - PATCH `/admin/products/{id}` (обновление)
  - DELETE `/admin/products/{id}` (удаление)
- [ ] Создать `internal/templates/admin/products/list.tmpl`, `form.tmpl`
- [ ] Протестировать CRUD

### День 28: Управление заказами (просмотр и смена статуса)
- [ ] Создать `internal/http/handlers/admin_orders_handler.go`:
  - GET `/admin/orders` (список с фильтрами по статусу)
  - GET `/admin/orders/{orderNumber}` (детали заказа)
  - PATCH `/admin/orders/{orderNumber}/status` (смена статуса)
- [ ] Создать `internal/templates/admin/orders/list.tmpl`, `detail.tmpl`
- [ ] Протестировать функционал

---

## Этап 10: Финальная полировка и тестирование MVP

### День 29: Обработка ошибок и логирование
- [ ] Добавить централизованную обработку ошибок в gin (middleware)
- [ ] Настроить структурированное логирование (можно `logrus` или `zap`)
- [ ] Добавить логирование всех важных операций (создание заказа, платежи, ошибки)
- [ ] Протестировать обработку ошибок

### День 30: Тестирование полного флоу и багфиксы
- [ ] Протестировать полный пользовательский флоу: регистрация → каталог → корзина → заказ → оплата → ЛК
- [ ] Протестировать админку: вход → управление товарами → просмотр заказов
- [ ] Исправить найденные баги
- [ ] Подготовить краткую документацию по запуску проекта (README.md)

---

## Дополнительные задачи (после MVP, если время позволяет)

- [ ] Добавить валидацию форм на бэкенде (можно использовать `validator` пакет)
- [ ] Добавить кеширование каталога в Redis
- [ ] Добавить метрики (можно Prometheus)
- [ ] Настроить graceful shutdown
- [ ] Добавить базовые unit-тесты для критичных сервисов
- [ ] Оптимизировать SQL-запросы (EXPLAIN ANALYZE)

---

## Примечания

- Каждый день предполагает работу в течение рабочего дня (6-8 часов).
- Если задача не укладывается в день, можно разбить её на два дня или упростить требования.
- После каждого этапа желательно делать небольшой демо для проверки работоспособности.
- При возникновении блокеров (например, проблемы с интеграцией Т-Банк) можно временно использовать mock-данные для продолжения разработки.
