-- Cобирает готовые сбалансированные комплекты
-- (Доска + Ботинки + Крепления), подходящие под анатомию.
CREATE OR REPLACE FUNCTION f_generate_smart_package(
    p_height_cm INT, 
    p_foot_size INT, 
    p_gender CHAR(1)
)
RETURNS TABLE (
    recommended_snowboard TEXT,
    recommended_boots TEXT,
    recommended_bindings TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (br_s.brand_name || ' ' || s.model || ' (' || s.snowboard_length || ' см)')::TEXT,
        (br_bt.brand_name || ' ' || bt.model || ' (р. ' || bt.foot_size || ')')::TEXT,
        (br_bd.brand_name || ' (размер ' || bd.binding_size || ')')::TEXT
    FROM Snowboards s
    JOIN Brands br_s ON s.brand_id = br_s.brand_id
    
    CROSS JOIN Boots bt
    JOIN Brands br_bt ON bt.brand_id = br_bt.brand_id
    
    CROSS JOIN Bindings bd
    JOIN Brands br_bd ON bd.brand_id = br_bd.brand_id
    
    WHERE 
        s.snowboard_length BETWEEN (p_height_cm - 23) AND (p_height_cm - 17)
        
        AND bt.foot_size = p_foot_size 
        AND (bt.sex = p_gender OR bt.sex IS NULL)
        
        AND bd.binding_size = CASE 
            WHEN p_foot_size <= 39 THEN 'S'::VARCHAR
            WHEN p_foot_size BETWEEN 40 AND 42 THEN 'M'::VARCHAR
            ELSE 'L'::VARCHAR
        END
        
        AND s.snowboard_id NOT IN (
            SELECT DISTINCT ri.snowboard_id FROM Rentals_Item ri 
            JOIN Rentals r ON ri.rental_id = r.rental_id WHERE r.return_date > NOW() AND ri.snowboard_id IS NOT NULL
        )
        AND bt.boots_id NOT IN (
            SELECT DISTINCT ri.boots_id FROM Rentals_Item ri 
            JOIN Rentals r ON ri.rental_id = r.rental_id WHERE r.return_date > NOW() AND ri.boots_id IS NOT NULL
        )
        AND bd.binding_id NOT IN (
            SELECT DISTINCT ri.binding_id FROM Rentals_Item ri 
            JOIN Rentals r ON ri.rental_id = r.rental_id WHERE r.return_date > NOW() AND ri.binding_id IS NOT NULL
        )
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;