--================================================================
-- ЗАВДАННЯ 1.
--================================================================
-- Створення схеми та імпорт даних
CREATE SCHEMA pandemic;
USE pandemic;
--================================================================
-- ЗАВДАННЯ 2.
--================================================================
-- Нормалізація до 3НФ
-- 1. Таблиця довідника країн
CREATE TABLE entities (
    entity_id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255),
    code VARCHAR(10)
);

INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

-- 2. Основна таблиця з посиланням
CREATE TABLE infectious_cases_norm (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT,
    year INT,
    number_rabies FLOAT,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id)
);

INSERT INTO infectious_cases_norm (entity_id, year, number_rabies)
SELECT 
    e.entity_id,
    ic.Year,
    NULLIF(ic.Number_rabies, '')
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity
   AND ic.Code = e.code;

-- Кількість рядків
SELECT COUNT(*) FROM infectious_cases;
--================================================================
-- ЗАВДАННЯ 3.
--================================================================
-- Аналітика Number_rabies
SELECT 
    e.entity,
    e.code,
    AVG(ic.number_rabies) AS avg_rabies,
    MIN(ic.number_rabies) AS min_rabies,
    MAX(ic.number_rabies) AS max_rabies,
    SUM(ic.number_rabies) AS sum_rabies
FROM infectious_cases_norm ic
JOIN entities e ON ic.entity_id = e.entity_id
WHERE ic.number_rabies IS NOT NULL
GROUP BY e.entity, e.code
ORDER BY avg_rabies DESC
LIMIT 10;
--================================================================
-- ЗАВДАННЯ 4.
--================================================================
-- Різниця в роках (вбудовані функції)
SELECT
    `year`,
    STR_TO_DATE(CONCAT(`year`, '-01-01'), '%Y-%m-%d') AS start_date,
    CURDATE() AS today,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(`year`, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    ) AS year_diff
FROM infectious_cases_norm
WHERE `year` <> ''
LIMIT 10;
--================================================================
-- ЗАВДАННЯ 5.
--================================================================
-- Власна функція
DROP FUNCTION IF EXISTS year_diff_from_now;
DELIMITER $$

CREATE FUNCTION year_diff_from_now(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    );
END $$

DELIMITER ;

-- Використання функції
SELECT 
    year,
    year_diff_from_now(year) AS year_difference
FROM infectious_cases_norm
LIMIT 10;
--================================================================


