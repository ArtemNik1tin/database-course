-- Бренды, у которых в прокате более 5 сноубордов
SELECT brand_id, COUNT(snowboards.snowboard_id)
FROM brands
JOIN snowboards ON brands.brand_id = snowboards.brand_id
GROUP BY brands.brand_name
HAVING COUNT(snowboards.snowboard_id) > 5; 