-- Сколько дней осталось до окончания срока действия вакцинации от бешенства (код бешенства - R) у животного с чипом X,
-- которого нашли в дату Y?
SELECT 
    ((registry.vaccination_date + make_interval(months => vaccination_list.validity_period_months))::date - lost_list.finding_date) AS days_left
FROM registry
JOIN vaccination_list ON registry.vaccination_id = vaccination_list.vaccination_id
JOIN lost_list ON lost_list.chip = registry.chip
WHERE lost_list.finding_date = '2022-05-04'
  AND registry.chip = 643097282666151
  AND vaccination_list.vaccination_code LIKE '%R%'
  AND registry.vaccination_date <= lost_list.finding_date
ORDER BY registry.vaccination_date DESC
LIMIT 1;