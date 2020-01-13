CREATE DATABASE example;
USE example;
DROP TABLE IF EXISTS users;
CREATE TABLE users(id SERIAL PRIMARY KEY COMMENT 'Столбец числовой id', 
name VARCHAR(255) COMMENT 'Столбец с именами пользователей') COMMENT='Пользователи';

