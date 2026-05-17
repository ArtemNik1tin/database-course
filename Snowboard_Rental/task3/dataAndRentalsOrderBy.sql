-- Дата и количество аренд в день по убыванию
SELECT rental_date::date, COUNT(1)
FROM Rentals
GROUP BY rental_date::date
ORDER BY COUNT(1) DESC;