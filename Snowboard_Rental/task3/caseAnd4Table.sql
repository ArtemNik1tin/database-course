-- Отчет по клиентам с определенными номерами.
SELECT
    clients.full_name,
    snowboards.model,
    CASE 
        WHEN snowboards.snowboard_length < 150 THEN 'Short'
        WHEN snowboards.snowboard_length BETWEEN 150 AND 160 THEN 'Medium'
        ELSE 'Long'
    END AS Category
FROM clients
JOIN rentals ON rentals.client_id = clients.client_id
JOIN rentals_item ON rentals_item.rental_id = rentals.rental_id
JOIN snowboards ON rentals_item.snowboard_id = snowboards.snowboard_id
WHERE clients.phone_number LIKE '+7900%'
