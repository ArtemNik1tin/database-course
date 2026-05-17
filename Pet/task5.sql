-- Все прививки животного с чипом X пронумерованные по порядку.
SELECT 
    registry.vaccination_date,
    registry.vaccination_id,
    ROW_NUMBER() OVER(ORDER BY registry.vaccination_date ASC, registry.registry_id ASC) AS num
FROM registry
WHERE registry.chip = 643097282666151;

-- Для ветеринарной клиники с кодом Y 
-- выведите накопительным итогом количество сделанных прививок за весь период
-- (когда они в принципе делали прививки)
SELECT 
    registry.vaccination_date,
	registry.vaccination_id,
	COUNT(1) 
	OVER(
		ORDER BY registry.vaccination_date ASC, registry.registry_id ASC
	) AS number_of_vaccinations 
FROM registry
WHERE registry.clinic_pet_id LIKE '1024/%'

-- Коды владельцев животных и суммы штрафов для каждого из них
-- (штраф 1 рубль за каждый день,
-- когда животному требовалась прививка от бешенства, а предыдущая уже закончилась) на дату 1/1/2022
SELECT 
	owner_id,
	SUM(
		CASE WHEN next_vac_date - end_date_of_vaccination <= 0
		THEN 0
		ELSE next_vac_date - end_date_of_vaccination
		END
	) AS penalties
FROM (
SELECT
	chip_list.owner_id,
	vaccination_list.vaccination_code,
	(registry.vaccination_date + make_interval(months => vaccination_list.validity_period_months))::date
	AS end_date_of_vaccination,
	CASE WHEN LEAD(registry.vaccination_date)
	OVER(PARTITION BY registry.chip ORDER BY registry.vaccination_date) >= '1-1-2022'
	OR LEAD(registry.vaccination_date)
	OVER(PARTITION BY registry.chip ORDER BY registry.vaccination_date) IS NULL
		THEN '1-1-2022'
	ELSE
		LEAD(registry.vaccination_date) OVER(PARTITION BY registry.chip ORDER BY registry.vaccination_date)
	END AS next_vac_date
FROM chip_list
JOIN registry ON registry.chip = chip_list.chip
JOIN vaccination_list ON registry.vaccination_id = vaccination_list.vaccination_id
WHERE vaccination_list.vaccination_code LIKE '%R%'
) AS penalties
GROUP BY owner_id