# 🏨 Base de Datos: Gestión de Alojamientos Turísticos

## 🛠️ Motor de Base de Datos

| Parámetro        | Detalle                      |
|------------------|------------------------------|
| **Motor**        | PostgreSQL                   |
| **Versión**      | 18.4                         |
| **Herramienta**  | pg_dump 18.3                 |
| **Codificación** | UTF-8                        |
| **Schema**       | `tourism`                    |
| **Owner**        | `doadmin`                    |

> Todas las tablas, secuencias, funciones e índices residen dentro del schema **`tourism`**.  
> Para ejecutar cualquier consulta sin prefijo usa: `SET search_path TO tourism;`

---

## 📐 Esquema de la Base de Datos

### Diagrama de Relaciones

```
owners ──────────────────────────────────────┐
   │                                         │
   │ 1:N                                     │
   ▼                                         │
accommodations ◄── accommodation_types       │
   │    │                                    │
   │    └──── locations                      │
   │                                         │
   │ 1:N      N:M                            │
   ▼           ▼                             │
 rooms    accommodation_amenities            │
   │           │                             │
   │           └──── amenities              │
   │                                         │
guests ──────────────────────────────────────┘
   │
   │ 1:N
   ▼
bookings ◄── booking_statuses
   │    │
   │    ├──── booking_guests
   │    │
   │    ├──── payments
   │    │
   │    └──── reviews
```

---

## 📋 Tablas

### 1. `tourism.owners` — Propietarios

Almacena los propietarios de los alojamientos.

| Columna         | Tipo                  | Restricción     | Descripción                        |
|-----------------|-----------------------|-----------------|------------------------------------|
| `owner_id`      | `bigint`              | PK, SERIAL      | Identificador único del propietario |
| `first_name`    | `varchar(100)`        | NOT NULL        | Nombre                             |
| `last_name`     | `varchar(100)`        | NOT NULL        | Apellido                           |
| `company_name`  | `varchar(150)`        | NULLABLE        | Nombre de la empresa (opcional)    |
| `email`         | `varchar(150)`        | NOT NULL, UNIQUE| Correo electrónico                 |
| `phone`         | `varchar(30)`         | NULLABLE        | Teléfono                           |
| `tax_id`        | `varchar(50)`         | NULLABLE        | NIT / RUC / Tax ID fiscal          |
| `address_line1` | `varchar(150)`        | NULLABLE        | Dirección principal                |
| `address_line2` | `varchar(150)`        | NULLABLE        | Dirección secundaria               |
| `city`          | `varchar(100)`        | NULLABLE        | Ciudad                             |
| `state`         | `varchar(100)`        | NULLABLE        | Estado / Departamento              |
| `country`       | `varchar(100)`        | NULLABLE        | País                               |
| `postal_code`   | `varchar(20)`         | NULLABLE        | Código postal                      |
| `created_at`    | `timestamp`           | NOT NULL, DEFAULT NOW() | Fecha de creación          |
| `updated_at`    | `timestamp`           | NOT NULL, DEFAULT NOW() | Última actualización       |

**Trigger:** `trg_owners_updated_at` → actualiza `updated_at` automáticamente en cada UPDATE.

---

### 2. `tourism.locations` — Ubicaciones

Centraliza las direcciones geográficas usadas por los alojamientos.

| Columna         | Tipo             | Restricción     | Descripción                      |
|-----------------|------------------|-----------------|----------------------------------|
| `location_id`   | `bigint`         | PK, SERIAL      | Identificador único              |
| `country`       | `varchar(100)`   | NOT NULL        | País                             |
| `state`         | `varchar(100)`   | NULLABLE        | Estado / Departamento            |
| `city`          | `varchar(100)`   | NOT NULL        | Ciudad                           |
| `district`      | `varchar(100)`   | NULLABLE        | Colonia / Barrio / Distrito      |
| `address_line1` | `varchar(150)`   | NOT NULL        | Dirección principal              |
| `address_line2` | `varchar(150)`   | NULLABLE        | Dirección secundaria             |
| `postal_code`   | `varchar(20)`    | NULLABLE        | Código postal                    |
| `latitude`      | `numeric(9,6)`   | NULLABLE        | Latitud geográfica               |
| `longitude`     | `numeric(9,6)`   | NULLABLE        | Longitud geográfica              |
| `created_at`    | `timestamp`      | NOT NULL, DEFAULT NOW() | Fecha de creación        |

---

### 3. `tourism.accommodation_types` — Tipos de Alojamiento

Catálogo de categorías de alojamiento.

| Columna                  | Tipo           | Restricción | Descripción               |
|--------------------------|----------------|-------------|---------------------------|
| `accommodation_type_id`  | `integer`      | PK, SERIAL  | Identificador único       |
| `type_name`              | `varchar(50)`  | NOT NULL    | Nombre del tipo           |
| `description`            | `text`         | NULLABLE    | Descripción del tipo      |

**Valores disponibles:**

| ID | Tipo        | Descripción                          |
|----|-------------|--------------------------------------|
| 1  | Hotel       | Traditional hotel accommodation      |
| 2  | Hostel      | Shared budget accommodation          |
| 3  | Apartment   | Private apartment for short stays    |
| 4  | House       | Entire residential house             |
| 5  | Villa       | Luxury private villa                 |
| 6  | Cabin       | Small rural or nature-based lodging  |
| 7  | Resort      | Full-service vacation resort         |
| 8  | Guesthouse  | Small privately owned lodging        |

---

### 4. `tourism.accommodations` — Alojamientos

Tabla principal que registra cada propiedad disponible para reserva.

| Columna                  | Tipo             | Restricción            | Descripción                       |
|--------------------------|------------------|------------------------|-----------------------------------|
| `accommodation_id`       | `bigint`         | PK, SERIAL             | Identificador único               |
| `owner_id`               | `bigint`         | FK → owners            | Propietario                       |
| `accommodation_type_id`  | `integer`        | FK → accommodation_types | Tipo de alojamiento             |
| `location_id`            | `bigint`         | FK → locations         | Ubicación                         |
| `name`                   | `varchar(150)`   | NOT NULL               | Nombre del alojamiento            |
| `description`            | `text`           | NULLABLE               | Descripción detallada             |
| `max_guests`             | `integer`        | NOT NULL, CHECK > 0    | Máximo de huéspedes               |
| `bedroom_count`          | `integer`        | NOT NULL, DEFAULT 1    | Número de habitaciones            |
| `bathroom_count`         | `integer`        | NOT NULL, DEFAULT 1    | Número de baños                   |
| `base_price_per_night`   | `numeric(10,2)`  | NOT NULL, CHECK >= 0   | Precio base por noche             |
| `currency_code`          | `char(3)`        | NOT NULL, DEFAULT 'USD'| Código de moneda (ISO 4217)       |
| `check_in_time`          | `time`           | NULLABLE               | Hora de check-in                  |
| `check_out_time`         | `time`           | NULLABLE               | Hora de check-out                 |
| `is_active`              | `boolean`        | NOT NULL, DEFAULT TRUE | Estado activo/inactivo            |
| `created_at`             | `timestamp`      | NOT NULL, DEFAULT NOW()| Fecha de creación                 |
| `updated_at`             | `timestamp`      | NOT NULL, DEFAULT NOW()| Última actualización              |

**Trigger:** `trg_accommodations_updated_at`

---

### 5. `tourism.rooms` — Habitaciones

Habitaciones individuales dentro de un alojamiento.

| Columna               | Tipo             | Restricción          | Descripción                     |
|-----------------------|------------------|----------------------|---------------------------------|
| `room_id`             | `bigint`         | PK, SERIAL           | Identificador único             |
| `accommodation_id`    | `bigint`         | FK → accommodations  | Alojamiento al que pertenece    |
| `room_name`           | `varchar(100)`   | NOT NULL             | Nombre de la habitación         |
| `room_code`           | `varchar(50)`    | NULLABLE             | Código interno (ej: `1-001`)    |
| `floor_number`        | `integer`        | NULLABLE             | Piso en el que se encuentra     |
| `capacity`            | `integer`        | NOT NULL, CHECK > 0  | Capacidad máxima de personas    |
| `bed_count`           | `integer`        | NOT NULL, DEFAULT 1  | Número de camas                 |
| `room_price_per_night`| `numeric(10,2)`  | NULLABLE, CHECK >= 0 | Precio específico de la habitación |
| `is_available`        | `boolean`        | NOT NULL, DEFAULT TRUE| Disponibilidad actual          |
| `created_at`          | `timestamp`      | NOT NULL, DEFAULT NOW()| Fecha de creación              |
| `updated_at`          | `timestamp`      | NOT NULL, DEFAULT NOW()| Última actualización           |

**FK:** `fk_room_accommodation` → `ON DELETE CASCADE`  
**Trigger:** `trg_rooms_updated_at`

---

### 6. `tourism.guests` — Huéspedes

Personas que realizan reservas.

| Columna                    | Tipo            | Restricción            | Descripción                      |
|----------------------------|-----------------|------------------------|----------------------------------|
| `guest_id`                 | `bigint`        | PK, SERIAL             | Identificador único              |
| `first_name`               | `varchar(100)`  | NOT NULL               | Nombre                           |
| `last_name`                | `varchar(100)`  | NOT NULL               | Apellido                         |
| `email`                    | `varchar(150)`  | NOT NULL, UNIQUE       | Correo electrónico               |
| `phone`                    | `varchar(30)`   | NULLABLE               | Teléfono                         |
| `date_of_birth`            | `date`          | NULLABLE               | Fecha de nacimiento              |
| `nationality`              | `varchar(100)`  | NULLABLE               | Nacionalidad / país de origen    |
| `passport_number`          | `varchar(50)`   | NULLABLE               | Número de pasaporte              |
| `emergency_contact_name`   | `varchar(150)`  | NULLABLE               | Nombre del contacto de emergencia|
| `emergency_contact_phone`  | `varchar(30)`   | NULLABLE               | Teléfono del contacto de emergencia |
| `created_at`               | `timestamp`     | NOT NULL, DEFAULT NOW()| Fecha de registro                |
| `updated_at`               | `timestamp`     | NOT NULL, DEFAULT NOW()| Última actualización             |

**Trigger:** `trg_guests_updated_at`

---

### 7. `tourism.booking_statuses` — Estados de Reserva

Catálogo de estados posibles para una reserva.

| Columna             | Tipo           | Restricción | Descripción              |
|---------------------|----------------|-------------|--------------------------|
| `booking_status_id` | `integer`      | PK, SERIAL  | Identificador único      |
| `status_name`       | `varchar(50)`  | NOT NULL    | Nombre del estado        |
| `description`       | `text`         | NULLABLE    | Descripción del estado   |

---

### 8. `tourism.bookings` — Reservas

Tabla central del negocio. Registra cada reserva realizada.

| Columna              | Tipo             | Restricción              | Descripción                          |
|----------------------|------------------|--------------------------|--------------------------------------|
| `booking_id`         | `bigint`         | PK, SERIAL               | Identificador único                  |
| `guest_id`           | `bigint`         | FK → guests              | Huésped que reserva                  |
| `accommodation_id`   | `bigint`         | FK → accommodations      | Alojamiento reservado                |
| `room_id`            | `bigint`         | FK → rooms, NULLABLE     | Habitación específica (opcional)     |
| `booking_status_id`  | `integer`        | FK → booking_statuses    | Estado de la reserva                 |
| `check_in_date`      | `date`           | NOT NULL                 | Fecha de entrada                     |
| `check_out_date`     | `date`           | NOT NULL, CHECK > check_in | Fecha de salida                    |
| `adult_count`        | `integer`        | NOT NULL, DEFAULT 1      | Cantidad de adultos                  |
| `child_count`        | `integer`        | NOT NULL, DEFAULT 0      | Cantidad de niños                    |
| `total_nights`       | `integer`        | **GENERADO** (STORED)    | Noches = check_out − check_in        |
| `subtotal_amount`    | `numeric(10,2)`  | NOT NULL, CHECK >= 0     | Subtotal antes de impuestos          |
| `tax_amount`         | `numeric(10,2)`  | NOT NULL, DEFAULT 0      | Monto de impuestos                   |
| `discount_amount`    | `numeric(10,2)`  | NOT NULL, DEFAULT 0      | Descuento aplicado                   |
| `total_amount`       | `numeric(10,2)`  | NOT NULL, CHECK >= 0     | Total final a pagar                  |
| `special_requests`   | `text`           | NULLABLE                 | Peticiones especiales del huésped    |
| `booking_reference`  | `varchar(50)`    | NOT NULL, UNIQUE         | Código único de reserva (ej: BK-XXX) |
| `booked_at`          | `timestamp`      | NOT NULL, DEFAULT NOW()  | Momento en que se realizó la reserva |
| `created_at`         | `timestamp`      | NOT NULL, DEFAULT NOW()  | Fecha de creación del registro       |
| `updated_at`         | `timestamp`      | NOT NULL, DEFAULT NOW()  | Última actualización                 |

> ⚠️ `total_nights` es una **columna generada** (`GENERATED ALWAYS AS ... STORED`). No se puede insertar ni actualizar directamente.

**Trigger:** `trg_bookings_updated_at`

---

### 9. `tourism.booking_guests` — Huéspedes de la Reserva

Detalle de las personas adicionales incluidas en una reserva.

| Columna            | Tipo            | Restricción           | Descripción                     |
|--------------------|-----------------|-----------------------|---------------------------------|
| `booking_guest_id` | `bigint`        | PK, SERIAL            | Identificador único             |
| `booking_id`       | `bigint`        | FK → bookings         | Reserva a la que pertenece      |
| `first_name`       | `varchar(100)`  | NOT NULL              | Nombre del acompañante          |
| `last_name`        | `varchar(100)`  | NOT NULL              | Apellido del acompañante        |
| `age`              | `integer`       | NULLABLE, CHECK >= 0  | Edad                            |
| `document_number`  | `varchar(50)`   | NULLABLE              | Número de documento             |
| `created_at`       | `timestamp`     | NOT NULL, DEFAULT NOW()| Fecha de creación              |

**FK:** `fk_booking_guest_booking` → `ON DELETE CASCADE`

---

### 10. `tourism.payments` — Pagos

Registra los pagos asociados a cada reserva.

| Columna                 | Tipo             | Restricción          | Descripción                          |
|-------------------------|------------------|----------------------|--------------------------------------|
| `payment_id`            | `bigint`         | PK, SERIAL           | Identificador único                  |
| `booking_id`            | `bigint`         | FK → bookings        | Reserva pagada                       |
| `payment_date`          | `timestamp`      | NOT NULL, DEFAULT NOW()| Fecha y hora del pago              |
| `amount`                | `numeric(10,2)`  | NOT NULL, CHECK >= 0 | Monto pagado                         |
| `payment_method`        | `varchar(50)`    | NOT NULL             | Método (`CreditCard`, `Cash`, `PayPal`, `BankTransfer`, `DebitCard`, `Crypto`) |
| `payment_status`        | `varchar(50)`    | NOT NULL             | Estado (`Completed`, `Failed`, `Refunded`, `Pending`) |
| `transaction_reference` | `varchar(100)`   | NULLABLE             | UUID de la transacción               |
| `notes`                 | `text`           | NULLABLE             | Observaciones                        |
| `created_at`            | `timestamp`      | NOT NULL, DEFAULT NOW()| Fecha de creación                  |

**FK:** `fk_payment_booking` → `ON DELETE CASCADE`

---

### 11. `tourism.reviews` — Reseñas

Valoraciones que los huéspedes dejan sobre los alojamientos.

| Columna            | Tipo             | Restricción                       | Descripción                      |
|--------------------|------------------|-----------------------------------|----------------------------------|
| `review_id`        | `bigint`         | PK, SERIAL                        | Identificador único              |
| `booking_id`       | `bigint`         | FK → bookings                     | Reserva evaluada                 |
| `guest_id`         | `bigint`         | FK → guests                       | Huésped que reseña               |
| `accommodation_id` | `bigint`         | FK → accommodations               | Alojamiento evaluado             |
| `rating`           | `integer`        | NOT NULL, CHECK (1 ≤ rating ≤ 5)  | Calificación del 1 al 5          |
| `review_title`     | `varchar(150)`   | NULLABLE                          | Título de la reseña              |
| `review_text`      | `text`           | NULLABLE                          | Texto completo de la reseña      |
| `review_date`      | `timestamp`      | NOT NULL, DEFAULT NOW()           | Fecha de la reseña               |
| `created_at`       | `timestamp`      | NOT NULL, DEFAULT NOW()           | Fecha de creación del registro   |

**FK:** `fk_review_booking` → `ON DELETE CASCADE`

---

### 12. `tourism.amenities` — Comodidades

Catálogo de servicios y amenidades disponibles.

| Columna        | Tipo            | Restricción | Descripción                     |
|----------------|-----------------|-------------|---------------------------------|
| `amenity_id`   | `integer`       | PK, SERIAL  | Identificador único             |
| `amenity_name` | `varchar(100)`  | NOT NULL    | Nombre de la amenidad           |
| `description`  | `text`          | NULLABLE    | Descripción                     |

**Valores disponibles:**

| ID | Nombre           | Descripción                        |
|----|------------------|------------------------------------|
| 1  | WiFi             | Wireless internet access           |
| 2  | Pool             | Swimming pool                      |
| 3  | Parking          | Private or public parking          |
| 4  | AirConditioning  | Air conditioning system            |
| 5  | Kitchen          | Cooking facilities                 |
| 6  | Breakfast        | Breakfast included                 |
| 7  | PetFriendly      | Pets are allowed                   |
| 8  | Gym              | Fitness center                     |
| 9  | Spa              | Spa and wellness services          |
| 10 | BeachAccess      | Direct beach access                |

---

### 13. `tourism.accommodation_amenities` — Relación Alojamiento–Amenidad

Tabla intermedia N:M que vincula alojamientos con sus comodidades.

| Columna            | Tipo      | Restricción              | Descripción                    |
|--------------------|-----------|--------------------------|--------------------------------|
| `accommodation_id` | `bigint`  | PK, FK → accommodations  | Alojamiento                    |
| `amenity_id`       | `integer` | PK, FK → amenities       | Amenidad                       |

**FK:**  
- `fk_accommodation_amenity_accommodation` → `ON DELETE CASCADE`  
- `fk_accommodation_amenity_amenity` → `ON DELETE CASCADE`

---

## ⚙️ Función y Triggers

### Función `tourism.set_updated_at()`

```sql
CREATE FUNCTION tourism.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
```

Se dispara automáticamente **antes de cada UPDATE** en las siguientes tablas:

| Trigger                          | Tabla           |
|----------------------------------|-----------------|
| `trg_owners_updated_at`          | `owners`        |
| `trg_accommodations_updated_at`  | `accommodations`|
| `trg_rooms_updated_at`           | `rooms`         |
| `trg_guests_updated_at`          | `guests`        |
| `trg_bookings_updated_at`        | `bookings`      |
| `trg_staff_users_updated_at`     | `staff_users`   |

---

## 🔑 Índices

| Índice                          | Tabla            | Columna               |
|---------------------------------|------------------|-----------------------|
| `idx_accommodations_owner_id`   | `accommodations` | `owner_id`            |
| `idx_bookings_accommodation_id` | `bookings`       | `accommodation_id`    |
| `idx_bookings_guest_id`         | `bookings`       | `guest_id`            |
| `idx_bookings_room_id`          | `bookings`       | `room_id`             |
| `idx_bookings_status_id`        | `bookings`       | `booking_status_id`   |
| `idx_bookings_check_in_date`    | `bookings`       | `check_in_date`       |
| `idx_bookings_check_out_date`   | `bookings`       | `check_out_date`      |
| `idx_payments_booking_id`       | `payments`       | `booking_id`          |
| `idx_reviews_accommodation_id`  | `reviews`        | `accommodation_id`    |
| `idx_reviews_guest_id`          | `reviews`        | `guest_id`            |
| `idx_rooms_accommodation_id`    | `rooms`          | `accommodation_id`    |

---

## 🚀 Cómo restaurar la base de datos

```bash
# 1. Crear la base de datos destino
createdb -U postgres tourism_db

# 2. Restaurar el dump
psql -U postgres -d tourism_db -f accommodation_database_task.sql

# 3. Verificar el schema
psql -U postgres -d tourism_db -c "\dn"

# 4. Listar las tablas
psql -U postgres -d tourism_db -c "\dt tourism.*"
```

---

## 📊 Resumen de Datos de Prueba

| Tabla                      | Registros |
|----------------------------|-----------|
| `owners`                   | 20        |
| `locations`                | 20        |
| `accommodation_types`      | 8         |
| `accommodations`           | 20        |
| `amenities`                | 10        |
| `accommodation_amenities`  | ~110      |
| `guests`                   | 100       |
| `booking_statuses`         | 6         |
| `bookings`                 | ~100      |
| `booking_guests`           | ~50       |
| `payments`                 | ~80       |
| `reviews`                  | 60        |
| `rooms`                    | ~80       |

---

## 📁 Archivos del Proyecto

```
📦 proyecto/
 ┣ 📄 README.md                      ← Este archivo
 ┣ 📄 accommodation_database_task.sql ← Dump completo (estructura + datos)
 ┗ 📄 20_consultas_postgresql.sql     ← 20 consultas CRUD y JOIN
```
