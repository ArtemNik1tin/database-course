-- Дата и количество аренд в этот день по убыванию
SELECT rental_date::date, COUNT(*)
FROM Rentals
GROUP BY rental_date::date
ORDER BY COUNT(*) DESC;