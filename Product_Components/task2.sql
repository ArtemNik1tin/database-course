WITH RECURSIVE bom AS (
    SELECT
        product_id,
        component_id,
        quantity,
        1 AS level
    FROM product_components
    WHERE product_id = 1

    UNION ALL

    SELECT 
        pc.product_id,
        pc.component_id,
        pc.quantity,
        bom.level + 1 AS level
    FROM product_components pc
    JOIN bom ON pc.product_id = bom.component_id
)
SELECT 
    bom.level, 
    products.name AS component_name, 
    bom.quantity
FROM bom
JOIN products ON products.id = bom.component_id;