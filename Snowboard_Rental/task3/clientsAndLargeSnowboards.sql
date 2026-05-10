-- Все клиенты, которые брали в аренду сноуборд длиннее 160 см
SELECT full_name
FROM clients
WHERE client_id IN (
    SELECT rentals.client_id
    FROM rentals
    JOIN rentals_item ON rentals.rental_id = rentals.rental_id
    JOIN snowboards ON rentals_item.snowboard_id = snowboards.snowboard_id
    WHERE snowboards.snowboard_length > 160
)