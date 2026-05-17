-- Бренды, у которых в прокате более 4 сноубордов
SELECT brands.brand_name, COUNT(snowboards.snowboard_id)
FROM brands
JOIN snowboards ON brands.brand_id = snowboards.brand_id
GROUP BY brands.brand_name
HAVING COUNT(snowboards.snowboard_id) > 4;