SELECT * FROM v_rental_duration_anomalies;

SELECT * FROM v_active_rentals;

SELECT * FROM v_boots_abc_analysis;

SELECT * FROM v_brand_compatibility_matrix;

SELECT * FROM v_lost_revenue_analysis;

SELECT 
    r.rental_id, 
    c.full_name, 
    f_calculate_dynamic_price(r.rental_id) AS total_calculated_price
FROM Rentals r
JOIN Clients c ON r.client_id = c.client_id
ORDER BY r.rental_id DESC
LIMIT 4;

SELECT f_verify_gear_safety(1, 1, 1) AS test_ok; 

SELECT f_verify_gear_safety(1, 6, 3) AS test_warning_board;


SELECT * FROM f_generate_smart_package(178, 42, 'M');