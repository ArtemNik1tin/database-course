-- WITH RECURSIVE check_cycles AS (
--     SELECT 
--         product_id, 
--         component_id, 
--         ARRAY[product_id, component_id] AS path,
--         FALSE AS is_cycle
--     FROM product_components

--     UNION ALL

--     SELECT
--         pc.product_id,
--         pc.component_id,
--         cc.path || pc.component_id AS path,
--         pc.component_id = ANY(cc.path) AS is_cycle
--     FROM product_components pc
--     JOIN check_cycles cc ON pc.product_id = cc.component_id
--     WHERE cc.is_cycle = FALSE
-- )
-- SELECT path FROM check_cycles WHERE is_cycle = TRUE;