DROP TABLE IF EXISTS product_components CASCADE;
DROP TABLE IF EXISTS products CASCADE;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    cost NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE product_components (
    product_id INTEGER REFERENCES products(id),
    component_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    PRIMARY KEY (product_id, component_id)
);

INSERT INTO products (id, name, cost) VALUES
(1, 'Ноутбук в сборе', 0.00),
(2, 'Корпус и экран', 0.00),
(3, 'Материнская плата', 0.00),
(4, 'Матрица экрана', 5000.00),
(5, 'Пластиковая крышка', 1200.00),
(6, 'Процессор CPU', 15000.00),
(7, 'Оперативная память RAM', 4000.00),
(8, 'Кулер охлаждения', 800.00),
(9, 'Отдельная плашка RAM (для розницы)', 4000.00);

INSERT INTO product_components (product_id, component_id, quantity) VALUES
(1, 2, 1),
(1, 3, 1),
(2, 4, 1),
(2, 5, 2),
(3, 6, 1),
(3, 7, 2),
(3, 8, 1);
-- (5, 1, 1); -- Cycle