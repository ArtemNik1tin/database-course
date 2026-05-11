-- Все сноуборды, ростовка которых БОЛЬШЕ,
-- чем средняя ростовка всех сноубордов в базе.
SELECT snowboard_length
FROM snowboards
WHERE snowboard_length > (
    SELECT AVG(snowboards.snowboard_length)
    FROM snowboards
);