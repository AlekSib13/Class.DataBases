CREATE DATABASE example;
USE example;
DROP TABLE IF EXISTS users;
CREATE TABLE users(id SERIAL PRIMARY KEY COMMENT '������� �������� id', 
name VARCHAR(255) COMMENT '������� � ������� �������������') COMMENT='������������';

