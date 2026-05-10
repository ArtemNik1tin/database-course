-- Cколько раз ботинки каждого размера брали в аренду
SELECT Boots.foot_size, COUNT(Boots.boots_id) FROM Boots
JOIN Rentals_item ON Boots.boots_id = Rentals_item.boots_id
GROUP BY Boots.foot_size