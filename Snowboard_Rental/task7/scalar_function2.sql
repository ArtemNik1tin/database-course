-- Размер креплений должен строго соответствовать размеру ноги
-- (например, ботинки 44 размера физически не влезут в крепления размера 'S' или 'M' — это приведёт к травме).
-- Функция возвращает текстовый статус: 'OK' или описание критического несоответствия.
CREATE OR REPLACE FUNCTION f_verify_gear_safety(sb_id INT, boots_id INT, bind_id INT)
RETURNS TEXT AS $$
DECLARE
    v_boot_size INT;
    v_bind_size VARCHAR(2);
    v_is_wide BOOLEAN;
BEGIN
    SELECT foot_size INTO v_boot_size FROM Boots WHERE Boots.boots_id = f_verify_gear_safety.boots_id;
    SELECT is_wide INTO v_is_wide FROM Snowboards WHERE Snowboards.snowboard_id = f_verify_gear_safety.sb_id;
    SELECT binding_size INTO v_bind_size FROM Bindings WHERE Bindings.binding_id = f_verify_gear_safety.bind_id;

    IF v_boot_size >= 43 AND v_bind_size NOT IN ('L', 'XL') THEN
        RETURN 'ОПАСНОСТЬ: Большой ботинок (' || v_boot_size || ') требует крепления размера L/XL. Текущие крепления малы!';
    END IF;
    
    IF v_boot_size <= 38 AND v_bind_size NOT IN ('S', 'M') THEN
        RETURN 'ОПАСНОСТЬ: Маленький ботинок (' || v_boot_size || ') будет болтаться в креплениях размера ' || v_bind_size || '!';
    END IF;

    IF v_boot_size >= 44 AND v_is_wide = FALSE THEN
        RETURN 'ВНИМАНИЕ: Для размера ноги ' || v_boot_size || ' необходим широкий сноуборд (is_wide = TRUE), иначе ботинок будет цеплять склон!';
    END IF;

    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;