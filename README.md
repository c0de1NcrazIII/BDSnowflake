# BigDataSnowflake — лабораторная работа №1

Нормализация исходных данных о продажах товаров для питомцев в модель **«снежинка»** (PostgreSQL).

## Структура репозитория

| Путь | Назначение |
|------|------------|
| `исходные данные/` | 10 CSV-файлов (`MOCK_DATA.csv` … `MOCK_DATA (9).csv`), 10 000 строк |
| `sql/ddl/` | Создание staging, измерений и факта |
| `sql/dml/` | Заполнение измерений и `fact_sales` из `mock_data` |
| `sql/checks/` | Контрольные запросы |
| `docker-compose.yml` | PostgreSQL с автоматической загрузкой |
| `docker/init/` | Скрипт инициализации при первом старте контейнера |

## Модель данных

**Факт:** `fact_sales` — количество и сумма продажи, ссылки на измерения.

**Измерения (снежинка):**

- `dim_country` ← `dim_customer`, `dim_seller`, `dim_city`
- `dim_city` ← `dim_store`, `dim_supplier`
- `dim_product_category` ← `dim_product`
- `dim_date`, `dim_customer`, `dim_seller`, `dim_product`, `dim_store`, `dim_supplier`

**Staging:** `mock_data` — плоская копия CSV.

## Запуск

Требуется [Docker](https://docs.docker.com/get-docker/) и Docker Compose.

```bash
docker compose up -d
```

При первом запуске контейнер:

1. создаёт таблицы (DDL);
2. импортирует все CSV из `исходные данные/`;
3. выполняет DML и заполняет хранилище.

Подключение к БД:

| Параметр | Значение |
|----------|----------|
| Host | `localhost` |
| Port | `5432` |
| Database | `petshop` |
| User | `petshop` |
| Password | `petshop` |

Проверка:

```bash
docker compose exec postgres psql -U petshop -d petshop -f /sql/checks/validation.sql
```

Ожидается: `mock_data` и `fact_sales` по **10 000** строк, `revenue_match = OK`.

Полный сброс и повторная инициализация:

```bash
docker compose down -v
docker compose up -d
```

## Ручной запуск SQL (без Docker)

1. Создать БД и выполнить файлы из `sql/ddl/` по порядку.
2. Импортировать CSV в `mock_data` (DBeaver или `\copy`).
3. Выполнить `sql/dml/01_dimensions.sql`, затем `sql/dml/02_facts.sql`.

## Исходное задание

Описание курса: репозиторий [MAIStudents/BDSnowflake](https://github.com/MAIStudents/BDSnowflake).
