-- Все прививки животного с чипом X пронумерованные по порядку.
SELECT 
    registry.vaccination_date,
    registry.vaccination_id,
    ROW_NUMBER() OVER(ORDER BY registry.vaccination_date DESC, registry.registry_id DESC) AS num
FROM registry
WHERE registry.chip = 643097282666151;

-- Для ветеринарной клиники с кодом Y 
-- выведите накопительным итогом количество сделанных прививок за весь период
-- (когда они в принципе делали прививки)
WITH daily_stats AS (
    SELECT 
        vaccination_date::date AS vaccination_date,
        COUNT(*) AS daily_count
    FROM registry
    WHERE clinic_pet_id LIKE '1024/%'
    GROUP BY vaccination_date::date
)
SELECT
    vaccination_date,
    daily_count,
    SUM(daily_count) OVER (ORDER BY vaccination_date ASC) AS cumulative_vaccinations
FROM daily_stats
ORDER BY vaccination_date;

-- Коды владельцев животных и суммы штрафов для каждого из них
-- (штраф 1 рубль за каждый день,
-- когда животному требовалась прививка от бешенства, а предыдущая уже закончилась) на дату 1/1/2022
WITH base_vaccinations AS (
    SELECT
        cl.owner_id,
        r.chip,
        (r.vaccination_date + make_interval(months => vl.validity_period_months))::date AS end_date,
        LEAD(r.vaccination_date) OVER (PARTITION BY r.chip ORDER BY r.vaccination_date) AS next_vac_date
    FROM chip_list cl
    JOIN registry r ON r.chip = cl.chip
    JOIN vaccination_list vl ON r.vaccination_id = vl.vaccination_id
    WHERE vl.vaccination_code LIKE '%R%'
	-- AND owner_id = 256249660464
),

calculated_days AS (
    SELECT 
        owner_id,
        CASE 
            WHEN end_date >= DATE '2022-01-01' THEN 0

			WHEN next_vac_date IS NULL OR next_vac_date >= DATE '2022-01-01' 
                THEN DATE '2022-01-01' - end_date
            
            ELSE next_vac_date - end_date
        END AS penalty_days
    FROM base_vaccinations
)

SELECT 
    owner_id,
    SUM(CASE WHEN penalty_days < 0 THEN 0 ELSE penalty_days END) AS penalties
FROM calculated_days
-- WHERE owner_id = 256249660464
GROUP BY owner_id;

-- owner_id: 256249660464
SELECT registry.vaccination_date FROM registry
WHERE chip = 643090010195663

SELECT chip, owner_id FROM chip_list WHERE chip = 643090010195663

SELECT chip, owner_id FROM chip_list WHERE owner_id = 256249660464