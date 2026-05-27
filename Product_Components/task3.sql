WITH RECURSIVE bom AS (
    SELECT
        product_id,
        component_id,
        quantity
    FROM product_components
    WHERE product_id = 1

    UNION ALL

    SELECT
        pc.product_id,
        pc.component_id,
        pc.quantity * bom.quantity AS quantity
    FROM product_components pc
    JOIN bom ON pc.product_id = bom.component_id
)
SELECT 
    'Ноутбук в сборе' AS product_name,
    SUM(bom.quantity * products.cost) AS total_calculated_cost
FROM bom
JOIN products ON products.id = bom.component_id;