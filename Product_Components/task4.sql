SELECT id, name 
FROM products
WHERE id NOT IN (
    SELECT component_id FROM product_components
);