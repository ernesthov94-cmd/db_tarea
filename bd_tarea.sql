INSERT INTO tourism.owners (
    first_name, last_name, company_name, email, phone,
    tax_id, address_line1, city, state, country, postal_code
)
VALUES
    (
        'María José', 'Hernández', 'Hospedajes Hernández S.A. de C.V.',
        'mariajose.hernandez@email.com', '+503-7123-4567',
        'SV-23456789',
        'Av. Roosevelt #210, Colonia Médica',
        'San Salvador', 'San Salvador', 'El Salvador', '01101'
    ),
    (
        'Diego', 'Fuentes', NULL,
        'diego.fuentes@email.com', '+503-6234-5678',
        'SV-34567890',
        'Calle Poniente #88, Residencial Las Flores',
        'Santa Tecla', 'La Libertad', 'El Salvador', '01501'
    ),
    (
        'Lucía', 'Morales', 'Turismo y Descanso Morales',
        'lucia.morales@email.com', '+503-7345-6789',
        'SV-45678901',
        'Blvd. Los Héroes #55, Colonia Miramonte',
        'San Salvador', 'San Salvador', 'El Salvador', '01102'
    ),
    (
        'Roberto', 'Castillo', NULL,
        'roberto.castillo@email.com', '+503-6456-7890',
        'SV-56789012',
        'Calle La Mascota #33, Colonia Maquilishuat',
        'San Salvador', 'San Salvador', 'El Salvador', '01103'
    ),
    (
        'Ana Patricia', 'Vásquez', 'Alojamientos del Pacífico S.A.',
        'ana.vasquez@email.com', '+503-7567-8901',
        'SV-67890123',
        'Av. Costera #12, Barrio El Centro',
        'La Libertad', 'La Libertad', 'El Salvador', '03101'
    ),
    (
        'Fernando', 'Aguilar', 'Grupo Hotelero Aguilar',
        'fernando.aguilar@email.com', '+503-6678-9012',
        'SV-78901234',
        'Calle Siemens #7, Colonia Escalón',
        'San Salvador', 'San Salvador', 'El Salvador', '01104'
    ),
    (
        'Claudia', 'Portillo', NULL,
        'claudia.portillo@email.com', '+503-7789-0123',
        'SV-89012345',
        'Calle Oriente #144, Barrio San Jacinto',
        'Soyapango', 'San Salvador', 'El Salvador', '01201'
    ),
    (
        'Jorge Luis', 'Mejía', 'Inversiones Mejía e Hijos',
        'jorge.mejia@email.com', '+503-6890-1234',
        'SV-90123456',
        'Av. Independencia #67, Colonia Flor Blanca',
        'San Salvador', 'San Salvador', 'El Salvador', '01105'
    ),
    (
        'Karla', 'Benítez', 'Benítez Rentas Turísticas',
        'karla.benitez@email.com', '+503-7901-2345',
        'SV-01234567',
        'Calle los Almendros #19, Colonia San Benito',
        'Antiguo Cuscatlán', 'La Libertad', 'El Salvador', '01503'
    ),
    (
        'Eduardo', 'Chávez', NULL,
        'eduardo.chavez@email.com', '+503-6012-3456',
        'SV-11223344',
        'Blvd. del Ejército #302, Colonia Ciudad Delgado',
        'Ciudad Delgado', 'San Salvador', 'El Salvador', '01202'
    )
RETURNING owner_id, first_name, last_name, email;

INSERT INTO tourism.accommodations (
    owner_id, accommodation_type_id, location_id,
    name, description, max_guests,
    bedroom_count, bathroom_count,
    base_price_per_night, currency_code,
    check_in_time, check_out_time, is_active
)
VALUES (
    1, 4, 19,
    'Casa Vista al Volcán',
    'Hermosa casa con vista panorámica al volcán Santa Ana, jardín privado y BBQ.',
    6, 3, 2,
    85.00, 'USD',
    '14:00', '11:00', TRUE
)
RETURNING accommodation_id, name, base_price_per_night;

INSERT INTO tourism.guests (
    first_name, last_name, email, phone,
    date_of_birth, nationality, passport_number
)
VALUES (
    'María', 'González', 'maria.gonzalez@gmail.com', '+502-5678-9012',
    '1990-05-15', 'Guatemala', 'GT12345678'
)
RETURNING guest_id, first_name, last_name;
 
-- Paso 2: insertar la reserva vinculada.
-- Se usan IDs reales: accommodation_id=1, booking_status_id=1 (Confirmed).
-- Ajusta guest_id al valor devuelto por el INSERT anterior.
INSERT INTO tourism.bookings (
    guest_id, accommodation_id, room_id, booking_status_id,
    check_in_date, check_out_date,
    adult_count, child_count,
    subtotal_amount, tax_amount, discount_amount, total_amount,
    booking_reference
)
VALUES (
    101, 1, NULL, 1,
    '2025-08-10', '2025-08-15',
    3, 1,
    340.00, 40.80, 0.00, 380.80,
    'BK-NUEVA001'
)
RETURNING booking_id, booking_reference, total_amount;

INSERT INTO tourism.payments (
    booking_id, amount, payment_method, payment_status,
    transaction_reference, notes
)
VALUES (
    101, 380.80, 'CreditCard', 'Completed',
    gen_random_uuid()::text,
    'Pago completo al momento de la reserva'
)
RETURNING payment_id, booking_id, amount, payment_status;

SELECT
    a.accommodation_id,
    a.name,
    at.type_name                        AS tipo,
    l.city                              AS ciudad,
    l.country                           AS pais,
    a.base_price_per_night              AS precio_noche,
    a.currency_code                     AS moneda,
    a.max_guests                        AS capacidad_max
FROM tourism.accommodations a
INNER JOIN tourism.accommodation_types at
    ON a.accommodation_type_id = at.accommodation_type_id
INNER JOIN tourism.locations l
    ON a.location_id = l.location_id
WHERE a.is_active = TRUE
ORDER BY a.base_price_per_night ASC;

SELECT
    guest_id,
    first_name,
    last_name,
    email,
    phone,
    nationality,
    created_at::date AS fecha_registro
FROM tourism.guests
WHERE nationality = 'Guatemala'
ORDER BY last_name, first_name;

SELECT
    b.booking_id,
    b.booking_reference,
    b.guest_id,
    b.accommodation_id,
    b.check_in_date,
    b.check_out_date,
    b.total_nights,
    b.total_amount,
    bs.status_name                      AS estado
FROM tourism.bookings b
INNER JOIN tourism.booking_statuses bs
    ON b.booking_status_id = bs.booking_status_id
WHERE b.check_in_date BETWEEN '2025-07-01' AND '2025-09-30'
ORDER BY b.check_in_date;

UPDATE tourism.accommodations
SET
    base_price_per_night = 95.00,
    updated_at           = CURRENT_TIMESTAMP
WHERE accommodation_id = 1;
 
-- Verificación
SELECT accommodation_id, name, base_price_per_night, updated_at
FROM tourism.accommodations
WHERE accommodation_id = 1;

UPDATE tourism.bookings
SET
    booking_status_id = 5,
    updated_at        = CURRENT_TIMESTAMP
WHERE booking_id = 10;
 
-- Verificación
SELECT b.booking_id, bs.status_name, b.check_in_date, b.total_amount
FROM tourism.bookings b
INNER JOIN tourism.booking_statuses bs
    ON b.booking_status_id = bs.booking_status_id
WHERE b.booking_id = 10;

 DELETE FROM tourism.reviews
WHERE review_id = 3;
 
-- Verificación
SELECT COUNT(*) AS reseñas_con_id_3
FROM tourism.reviews
WHERE review_id = 3;

SELECT
    b.booking_id,
    b.booking_reference,
    g.first_name || ' ' || g.last_name  AS huesped,
    g.email,
    g.nationality,
    b.check_in_date,
    b.check_out_date,
    b.total_nights,
    b.adult_count + b.child_count        AS total_personas,
    b.total_amount,
    bs.status_name                       AS estado
FROM tourism.bookings b
INNER JOIN tourism.guests g
    ON b.guest_id = g.guest_id
INNER JOIN tourism.booking_statuses bs
    ON b.booking_status_id = bs.booking_status_id
ORDER BY b.check_in_date DESC;

 SELECT
    a.accommodation_id,
    a.name                               AS alojamiento,
    at.type_name                         AS tipo,
    l.city                               AS ciudad,
    l.country                            AS pais,
    a.base_price_per_night               AS precio_noche,
    a.currency_code                      AS moneda,
    o.first_name || ' ' || o.last_name   AS propietario,
    o.email                              AS email_propietario,
    COUNT(b.booking_id)                  AS total_reservas
FROM tourism.accommodations a
INNER JOIN tourism.accommodation_types at
    ON a.accommodation_type_id = at.accommodation_type_id
INNER JOIN tourism.locations l
    ON a.location_id = l.location_id
INNER JOIN tourism.owners o
    ON a.owner_id = o.owner_id
INNER JOIN tourism.bookings b
    ON b.accommodation_id = a.accommodation_id
GROUP BY
    a.accommodation_id, a.name, at.type_name,
    l.city, l.country, a.base_price_per_night, a.currency_code,
    o.first_name, o.last_name, o.email
ORDER BY total_reservas DESC;
 
 SELECT
    p.payment_id,
    p.amount                             AS monto_pagado,
    p.payment_method                     AS metodo_pago,
    p.payment_status                     AS estado_pago,
    p.payment_date::date                 AS fecha_pago,
    b.booking_reference,
    b.check_in_date,
    b.check_out_date,
    g.first_name || ' ' || g.last_name   AS huesped,
    g.email
FROM tourism.payments p
INNER JOIN tourism.bookings b
    ON p.booking_id = b.booking_id
INNER JOIN tourism.guests g
    ON b.guest_id = g.guest_id
ORDER BY p.payment_date DESC;

SELECT
    a.accommodation_id,
    a.name                               AS alojamiento,
    a.base_price_per_night,
    r.review_id,
    r.rating,
    r.review_title
FROM tourism.accommodations a
LEFT JOIN tourism.reviews r
    ON r.accommodation_id = a.accommodation_id
WHERE r.review_id IS NULL
ORDER BY a.name;

SELECT
    g.guest_id,
    g.first_name || ' ' || g.last_name   AS huesped,
    g.email,
    g.nationality,
    g.created_at::date                   AS fecha_registro
FROM tourism.guests g
LEFT JOIN tourism.bookings b
    ON b.guest_id = g.guest_id
WHERE b.booking_id IS NULL
ORDER BY g.created_at DESC;

SELECT
    a.name                               AS alojamiento,
    l.city                               AS ciudad,
    COUNT(p.payment_id)                  AS num_pagos,
    SUM(p.amount)                        AS total_ingresos,
    a.currency_code                      AS moneda
FROM tourism.accommodations a
INNER JOIN tourism.bookings b
    ON b.accommodation_id = a.accommodation_id
INNER JOIN tourism.payments p
    ON p.booking_id = b.booking_id
INNER JOIN tourism.locations l
    ON a.location_id = l.location_id
WHERE p.payment_status = 'Completed'
GROUP BY a.accommodation_id, a.name, l.city, a.currency_code
ORDER BY total_ingresos DESC;

SELECT
    a.name                               AS alojamiento,
    l.city                               AS ciudad,
    COUNT(r.review_id)                   AS total_reseñas,
    ROUND(AVG(r.rating), 2)              AS promedio_rating,
    MIN(r.rating)                        AS rating_min,
    MAX(r.rating)                        AS rating_max
FROM tourism.accommodations a
INNER JOIN tourism.reviews r
    ON r.accommodation_id = a.accommodation_id
INNER JOIN tourism.locations l
    ON a.location_id = l.location_id
GROUP BY a.accommodation_id, a.name, l.city
ORDER BY promedio_rating DESC;

SELECT
    a.accommodation_id,
    a.name                               AS alojamiento,
    at.type_name                         AS tipo,
    l.city                               AS ciudad,
    a.base_price_per_night               AS precio_noche,
    COUNT(b.booking_id)                  AS total_reservas
FROM tourism.accommodations a
INNER JOIN tourism.bookings b
    ON b.accommodation_id = a.accommodation_id
INNER JOIN tourism.accommodation_types at
    ON a.accommodation_type_id = at.accommodation_type_id
INNER JOIN tourism.locations l
    ON a.location_id = l.location_id
GROUP BY
    a.accommodation_id, a.name, at.type_name,
    l.city, a.base_price_per_night
ORDER BY total_reservas DESC
LIMIT 5;

SELECT
    a.accommodation_id,
    a.name                               AS alojamiento,
    l.city                               AS ciudad,
    COUNT(b.booking_id)                  AS total_reservas,
    ROUND(SUM(b.total_amount), 2)        AS ingresos_totales
FROM tourism.accommodations a
INNER JOIN tourism.bookings b
    ON b.accommodation_id = a.accommodation_id
INNER JOIN tourism.locations l
    ON a.location_id = l.location_id
GROUP BY a.accommodation_id, a.name, l.city
HAVING COUNT(b.booking_id) > 3
ORDER BY total_reservas DESC;

 SELECT
    a.accommodation_id,
    a.name,
    at.type_name                         AS tipo,
    l.city                               AS ciudad,
    l.country                            AS pais,
    a.base_price_per_night               AS precio_noche,
    a.currency_code                      AS moneda,
    a.max_guests,
    o.first_name || ' ' || o.last_name   AS propietario
FROM tourism.accommodations a
INNER JOIN tourism.accommodation_types at
    ON a.accommodation_type_id = at.accommodation_type_id
INNER JOIN tourism.locations l
    ON a.location_id = l.location_id
INNER JOIN tourism.owners o
    ON a.owner_id = o.owner_id
WHERE a.base_price_per_night = (
    SELECT MAX(base_price_per_night)
    FROM tourism.accommodations
    WHERE is_active = TRUE
)
AND a.is_active = TRUE;
  