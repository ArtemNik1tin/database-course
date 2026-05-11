-- full_name клиентов, чей client_id находится в списке тех,
-- кто совершал аренду ботинок с brand_id = 1
SELECT clients.full_name
FROM clients
WHERE client_id IN (
    SELECT rentals.client_id
    FROM rentals
    JOIN rentals_item ON rentals_item.rental_id = rentals.rental_id
    JOIN boots ON rentals_item.boots_id = boots.boots_id
    WHERE boots.brand_id = 1
);