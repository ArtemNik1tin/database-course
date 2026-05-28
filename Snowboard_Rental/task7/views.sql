DROP VIEW IF EXISTS v_rental_duration_anomalies CASCADE;
DROP VIEW IF EXISTS v_active_rentals CASCADE;
DROP VIEW IF EXISTS v_boots_abc_analysis CASCADE;
DROP VIEW IF EXISTS v_brand_compatibility_matrix CASCADE;
DROP VIEW IF EXISTS v_lost_revenue_analysis CASCADE;

-- Находит вещи, которые находятся в прокате подозрительно долго 
-- (дольше утроенного среднего времени проката). Сигнализирует о краже или потере.
CREATE OR REPLACE VIEW v_rental_duration_anomalies AS
WITH duration_calc AS (
    SELECT 
        ri.rental_item_id,
        r.rental_id,
        c.full_name AS client_name,
        EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600 AS current_duration_hours,
        AVG(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600) OVER() AS global_avg_duration_hours
    FROM Rentals_Item ri
    JOIN Rentals r ON ri.rental_id = r.rental_id
    JOIN Clients c ON r.client_id = c.client_id
)
SELECT 
    rental_item_id,
    rental_id,
    client_name,
    ROUND(current_duration_hours::NUMERIC, 1) AS duration_hours,
    ROUND(global_avg_duration_hours::NUMERIC, 1) AS average_market_hours,
    ROUND((current_duration_hours - global_avg_duration_hours)::NUMERIC, 1) AS excess_hours
FROM duration_calc
WHERE current_duration_hours > (global_avg_duration_hours * 3)
ORDER BY excess_hours DESC;


-- Выводит подробную информацию о клиентах и инвентаре, который 
-- находится на склоне прямо сейчас.
CREATE OR REPLACE VIEW v_active_rentals AS
SELECT 
    ri.rental_item_id,
    r.rental_date,
    r.return_date,
    c.full_name,
    c.phone_number,
    
    b_sb.brand_name || ' ' || s.model || ' (' || s.snowboard_length || ' см)' AS snowboard_info,
    
    b_bt.brand_name || ' ' || bt.model || ' (размер: ' || bt.foot_size || ')' AS boots_info,
    
    b_bd.brand_name || ' (размер: ' || bd.binding_size || ')' AS binding_info
FROM Rentals_Item ri
JOIN Rentals r ON r.rental_id = ri.rental_id
JOIN Clients c ON r.client_id = c.client_id
LEFT JOIN Snowboards s ON ri.snowboard_id = s.snowboard_id
LEFT JOIN Brands b_sb ON s.brand_id = b_sb.brand_id

LEFT JOIN Boots bt ON ri.boots_id = bt.boots_id
LEFT JOIN Brands b_bt ON bt.brand_id = b_bt.brand_id

LEFT JOIN Bindings bd ON ri.binding_id = bd.binding_id
LEFT JOIN Brands b_bd ON bd.brand_id = b_bd.brand_id
WHERE r.return_date > NOW();


-- Делит размеры ботинок по категориям востребованности:
-- Категория А (Топ-40% спроса), B (Следующие 40%), C (Редкие, оставшиеся 20%).
CREATE OR REPLACE VIEW v_boots_abc_analysis AS
WITH sizes_calculated AS (
    SELECT 
        sex,
        foot_size,
        COUNT(ri.rental_item_id) AS rentals_count,
        SUM(COUNT(ri.rental_item_id)) OVER(PARTITION BY sex ORDER BY COUNT(ri.rental_item_id) DESC) AS cumulative_rentals,
        SUM(COUNT(ri.rental_item_id)) OVER(PARTITION BY sex) AS total_rentals_for_gender
    FROM Boots b
    LEFT JOIN Rentals_Item ri ON b.boots_id = ri.boots_id
    GROUP BY sex, foot_size
)
SELECT 
    sex,
    foot_size,
    rentals_count,
    ROUND((cumulative_rentals * 100.0 / total_rentals_for_gender)::NUMERIC, 2) AS cumulative_percentage,
    CASE 
        WHEN (cumulative_rentals * 100.0 / total_rentals_for_gender) <= 40 THEN 'A (Высокий спрос)'
        WHEN (cumulative_rentals * 100.0 / total_rentals_for_gender) <= 80 THEN 'B (Средний спрос)'
        ELSE 'C (Низкий спрос)'
    END AS abc_class
FROM sizes_calculated
ORDER BY sex, rentals_count DESC;


-- Показывает, доски какого бренда чаще всего берут с креплениями ДРУГИХ 
-- брендов. Помогает понять, какие крепления закупать под какие сноуборды.
CREATE OR REPLACE VIEW v_brand_compatibility_matrix AS
SELECT 
    b_sb.brand_name AS snowboard_brand,
    b_bd.brand_name AS binding_brand,
    COUNT(*) AS joint_rentals_count,
    ROUND(
        COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER(PARTITION BY b_sb.brand_name), 
        2
    ) AS choice_percentage
FROM Rentals_Item ri
JOIN Snowboards s ON ri.snowboard_id = s.snowboard_id
JOIN Brands b_sb ON s.brand_id = b_sb.brand_id
JOIN Bindings bd ON ri.binding_id = bd.binding_id
JOIN Brands b_bd ON bd.brand_id = b_bd.brand_id
GROUP BY b_sb.brand_name, b_bd.brand_name
ORDER BY snowboard_brand, joint_rentals_count DESC;

-- Идентифицирует незаполненные позиции в договорах (например, прокат доски без ботинок)
-- и рассчитывает финансовые потери бизнеса на основе недополученной часовой ставки.
CREATE OR REPLACE VIEW v_lost_revenue_analysis AS
WITH package_gaps AS (
    SELECT 
        r.rental_id,
        c.full_name AS client_name,
        CEIL(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600)::INT AS rental_hours,
        
        (CASE WHEN ri.snowboard_id IS NOT NULL THEN 300 ELSE 0 END +
         CASE WHEN ri.boots_id IS NOT NULL THEN 150 ELSE 0 END +
         CASE WHEN ri.binding_id IS NOT NULL THEN 100 ELSE 0 END) AS actual_hourly_rate,
        
        (CASE WHEN ri.snowboard_id IS NULL THEN 300 ELSE 0 END +
         CASE WHEN ri.boots_id IS NULL THEN 150 ELSE 0 END +
         CASE WHEN ri.binding_id IS NULL THEN 100 ELSE 0 END) AS lost_hourly_rate
    FROM Rentals_Item ri
    JOIN Rentals r ON r.rental_id = ri.rental_id
    JOIN Clients c ON r.client_id = c.client_id
)
SELECT 
    rental_id,
    client_name,
    rental_hours,
    (actual_hourly_rate * rental_hours) AS earned_revenue,
    (lost_hourly_rate * rental_hours) AS lost_revenue,
    ((actual_hourly_rate + lost_hourly_rate) * rental_hours) AS ideal_potential_revenue
FROM package_gaps
ORDER BY lost_revenue DESC