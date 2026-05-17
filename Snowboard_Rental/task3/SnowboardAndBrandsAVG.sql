-- Средняя длина сноуборда для каждого бренда,
-- округлённая до двух знаков после запятой.
SELECT brands.brand_name, ROUND(AVG(snowboards.snowboard_length), 2)
FROM brands
JOIN snowboards ON snowboards.brand_id = brands.brand_id
GROUP BY brands.brand_name
