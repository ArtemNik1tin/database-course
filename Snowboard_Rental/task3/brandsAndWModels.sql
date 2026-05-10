-- Женские модели с размером меньше 39 в отсортированном порядке и их производитель
SELECT Brands.brand_name, Boots.model
FROM Boots
JOIN Brands ON Brands.brand_id = Boots.brand_id
WHERE sex = 'W' AND foot_size < 39
ORDER BY model;