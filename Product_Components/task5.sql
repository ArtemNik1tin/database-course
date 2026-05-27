WITH RECURSIVE dependency_chain AS (
    SELECT product_id, component_id 
    FROM product_components
    
    UNION ALL
    
    SELECT 
        pc.product_id, 
        dc.component_id
    FROM product_components pc
    JOIN dependency_chain dc ON pc.component_id = dc.product_id
)
SELECT component_id, COUNT(DISTINCT product_id) AS importance_rate
FROM dependency_chain
GROUP BY component_id
ORDER BY importance_rate DESC;