-- Первый час — самый дорогой (базовый тариф оборудования).
-- С каждым последующим часом цена падает на 10% (но не ниже 50% от начальной стоимости).
-- В выходные дни (суббота и воскресенье) применяется наценка 20%.
CREATE OR REPLACE FUNCTION f_calculate_dynamic_price(target_rental_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    rec RECORD;
    total_hours INT;
    base_hourly_rate NUMERIC := 0;
    calculated_sum NUMERIC := 0;
    is_weekend BOOLEAN;
    current_hour_rate NUMERIC;
BEGIN
    SELECT 
        CEIL(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600)::INT AS hours,
        (EXTRACT(DOW FROM r.rental_date) IN (0, 6)) AS weekend,
        ri.snowboard_id, ri.boots_id, ri.binding_id
    INTO rec
    FROM Rentals r
    JOIN Rentals_Item ri ON r.rental_id = ri.rental_id
    WHERE r.rental_id = target_rental_id;

    IF NOT FOUND THEN RETURN 0; END IF;

    IF rec.snowboard_id IS NOT NULL THEN base_hourly_rate := base_hourly_rate + 300; END IF;
    IF rec.boots_id IS NOT NULL THEN base_hourly_rate := base_hourly_rate + 150; END IF;
    IF rec.binding_id IS NOT NULL THEN base_hourly_rate := base_hourly_rate + 100; END IF;

    total_hours := rec.hours;
    FOR i IN 1..total_hours LOOP
        current_hour_rate := base_hourly_rate * GREATEST(1 - (i - 1) * 0.10, 0.50);
        calculated_sum := calculated_sum + current_hour_rate;
    END LOOP;

    IF rec.weekend THEN
        calculated_sum := calculated_sum * 1.20;
    END IF;

    RETURN ROUND(calculated_sum, 2);
END;
$$ LANGUAGE plpgsql;