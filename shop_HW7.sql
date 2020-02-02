DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (id SERIAL PRIMARY KEY, name VARCHAR(255) COMMENT 'Название раздела', 
UNIQUE unique_name(name(10))) 
COMMENT='Разделы интернет-магазина';

-- INSERT INTO catalogs VALUES (NULL,'Процессоры');
-- INSERT INTO catalogs (id,namee) VALUES (NULL, 'Мат.платы')

INSERT INTO catalogs (name) VALUES
('Процессоры' ),
('Мат. платы'),
('Видеокарты'),
('Куллеры');

delete from catalogs where id>2 LIMIT 1;

-- SELECT id,name FROM catalogs;

update catalogs set name='Процессоры AMD' where name='Процессоры';

SELECT id,name FROM catalogs;


DROP TABLE IF EXISTS cat;
CREATE TABLE cat (id SERIAL PRIMARY KEY, name VARCHAR(255) COMMENT 'Название раздела', 
UNIQUE unique_name(name(10))) 
COMMENT='Разделы интернет-магазина';


INSERT INTO cat SELECT*FROM catalogs;





INSERT INTO users (id,name,birthday_at) VALUES(1,'hello','1979-01-27');
SELECT*FROM users;

DROP TABLE IF EXISTS products;
CREATE TABLE products (id SERIAL PRIMARY KEY, name VARCHAR(255) COMMENT 'Название', description TEXT COMMENT 'Описание',
price DECIMAL(11,2) COMMENT 'Цена',catalog_id INT UNSIGNED, created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
KEY index_of_catalog_id (catalog_id)) COMMENT='Товарные позиции';


DROP TABLE IF EXISTS orders;
CREATE TABLE orders (id SERIAL PRIMARY KEY, user_id INT UNSIGNED, created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
KEY index_of_user_id(user_id)) 
COMMENT='Заказы';

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (id SERIAL PRIMARY KEY, order_id INT UNSIGNED, product_id INT UNSIGNED, total INT UNSIGNED
DEFAULT 1 COMMENT 'Количество заказанных товарных позиций', created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) COMMENT='Состав заказа'; 


DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (id SERIAL PRIMARY KEY, user_id INT UNSIGNED, product_id INT UNSIGNED, discounts FLOAT UNSIGNED
COMMENT 'Величина скидки от 0.0 до 1.0', started_at DATETIME, finished_at DATETIME, created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, KEY index_of_user_id(user_id),
KEY index_of_product_id(product_id))COMMENT='Скидки'; 

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (id SERIAL PRIMARY KEY, name VARCHAR(255) COMMENT 'Название', created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) COMMENT='Склады';

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (id SERIAL PRIMARY KEY, storehouse_id INT UNSIGNED, product_id INT UNSIGNED,
value INT UNSIGNED COMMENT 'Запас товарной позиции на складе', created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) COMMENT='Запасы на складе';




DROP TABLE IF EXISTS users;
CREATE TABLE users (id SERIAL PRIMARY KEY,  name VARCHAR(255) COMMENT 'Имя покупателя', birthday_at DATE COMMENT 'Дата рождения', 
created_at DATETIME DEFAULT CURRENT_TIMESTAMP, 
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) 
COMMENT='Покупатели';

-- Hometask Lesson №5
-- Task №1 "Operatios..."
-- Task №1.1 Since the Table users firstly had the data created_at and updated_at which were inserted together with 
-- values in other Tables (for instance name), we had to update it separately from the alteration of other  data:
USE shop;
UPDATE users SET created_at=NOW(), updated_at=NOW();
SELECT *FROM users;

-- Task №1.2. Since the Table users was first created correctly, let us change it in order to change it back then, while the
-- №1.2 Task is fulfilled.
USE shop;
TRUNCATE users;
ALTER TABLE  users MODIFY COLUMN created_at VARCHAR(255);
ALTER TABLE  users MODIFY COLUMN updated_at VARCHAR(255);
INSERT INTO users (name, birthday_at, created_at,updated_at) 
	VALUES 
	('Igor', '1979-01-19', '20.10.2017 8:10', '20.10.2017 8:10'),
	('Natalia' '1985-02-24','22.10.2017 8:15', '22.10.2017 8:15'),
	('Mikhail' '1992-07-15','22.11.2018 18:10', '22.11.2018 18:10')
	('Denis' '1993-12-11','18.07.2019 20:10', '18.07.2019 20:10');
SELECT *FROM users;
-- So this way we've changed the Table in order make it correspond to the Task№2
-- below is the fulfilment of the Task №2:
SELECT 	id, 
		name, 
		STR_TO_DATE(created_at, '%d.%m.%Y %H:%i') AS created_at, 
		STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i') AS updated_at 
		FROM users;


-- Task №1.3
INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES 
	(1, 1, 100),
	(1,2,2000),
	(2,3,800),
	(2,4,900),
	(2,5,0),
	(1,6,0);
SELECT*FROM storehouses_products;
SELECT *FROM storehouses_products ORDER BY CASE WHEN value LIKE 0 THEN TRUE ELSE FALSE END, value;

-- Task №2 "Aggregation..."
-- TASK №2.1
SELECT AVG(DATEDIFF(CURRENT_DATE(),birthday_at)/365.25) AS age FROM users;


ALTER TABLE users CHANGE created_at created_at DATETIME DEFAULT NOW();
ALTER TABLE users CHANGE updated_at updated_at DATETIME DEFAULT NOW();
UPDATE users SET created_at=STR_TO_DATE(created_at, '%d.%m.%Y %H:%i');
UPDATE users SET updated_at=STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');
UPDATE catalogs SET name='Кулеры' WHERE name='Куллеры';
UPDATE catalogs SET name='Мониторы' WHERE name='Screens';
TRUNCATE catalogs;
INSERT INTO catalogs(name) VALUES
	('Процессоры'),
	('Видеокарты'),
	('Материнские платы'),
	('Кулеры'),
	('Жесткие диски');
	



-- Homework№7
-- Task №1:
-- Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

USE shop;
SHOW TABLES;
SELECT*FROM users;
SELECT*FROM orders;

INSERT INTO orders(user_id) VALUES
	(1),
	(1),
	(1),
	(2),
	(4),
	(4);


-- Два варианта реализации:
-- Вариант №1: список пользователей, разместивших хотя бы 1 заказ в интернет магазине
SELECT users.id AS user_id, name, orders.id AS order_id, orders.created_at AS order_created_at, orders.updated_at AS order_updated_at 
	FROM users JOIN orders
		ON users.id=orders.user_id;
		

-- Вариант №2: общее количество заказов по каждому пользователю, разместившему хотя бы 1 заказ в интернет магазине
SELECT users.id AS user_id, name AS user_name, COUNT(user_id) AS total_number_of_orders_by_user
	FROM users JOIN orders
		ON users.id=orders.user_id
			GROUP BY name
				ORDER BY total_number_of_orders_by_user DESC;
		
		
		
		
-- Task №2:
-- Выведите список товаров products и разделов catalogs, который соответствует товару
SELECT*FROM catalogs;
SELECT*FROM products;

SELECT catalogs.id AS catalog_id, catalogs.name AS catalog_name, products.name AS product_name, price AS product_price
	FROM catalogs JOIN products
		ON catalogs.id=products.catalog_id;

		
-- Task №3
-- (по желанию) Пусть имеется таблица рейсов flights (id, from, to) 
-- и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. 
-- Выведите список рейсов flights с русскими названиями городов.		
		
CREATE TABLE flights
	(id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	from_city VARCHAR(255) NOT NULL,
	to_city VARCHAR(255) NOT NULL);


CREATE TABLE cities
	(id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	label VARCHAR(255) NOT NULL,
	name VARCHAR(255) NOT NULL);


DESC flights;
DESC cities;
	
INSERT INTO flights(from_city,to_city) VALUES
	('moscow','omsk'),
	('novgorod','kazan'),
	('irkutsk','moscow'),
	('omsk','irkutsk'),
	('moscow','kazan');

INSERT INTO cities(label,name) VALUES
	('moscow','Москва'),
	('irkutsk','Иркутск'),
	('novgorod','Новгород'),
	('kazan','Казань'),
	('omsk','Омск');



SELECT*FROM flights;
SELECT*FROM cities;



-- Два варианта реализации:
-- Вариант №1- решение с применением Join
SELECT 
	(SELECT name FROM cities WHERE label=flights.from_city) AS from_city, 
	(SELECT name FROM cities WHERE label=flights.to_city) AS to_city
	FROM flights JOIN cities
		WHERE flights.from_city=cities.label;


-- 2 Варианта решения:
-- Вариант №2- решение "без" Join	
SELECT 
	(SELECT name FROM cities WHERE label=flights.from_city) AS from_city, 
	(SELECT name FROM cities WHERE label=flights.to_city) AS to_city
	FROM flights;
	