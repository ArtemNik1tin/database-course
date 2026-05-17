-- Cреднее количество аренд на одного клиента.
SELECT ROUND(AVG(rental_count), 1) AS average_rentals_per_client
FROM (
    SELECT client_id, COUNT(1) AS rental_count
    FROM rentals
    GROUP BY client_id
);