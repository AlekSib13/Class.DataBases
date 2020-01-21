
-- DROP DATABASE
CREATE DATABASE vk;
USE vk


CREATE TABLE users (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	email VARCHAR(120) NOT NULL UNIQUE,
	phone VARCHAR(15) NOT NULL UNIQUE,
	`password` VARCHAR(15),
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	) COMMENT='Table which contains the main information referred to the user';


CREATE TABLE profiles (
	user_id INT UNSIGNED NOT NULL UNIQUE,
	birthday DATE,
	sex CHAR(1) NOT NULL,
	hometown VARCHAR(100),
	country VARCHAR(100),
	photo_id INT UNSIGNED,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
	) COMMENT='Table which contains profile info referred to the user';


CREATE TABLE family_statuses(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE) COMMENT='Table, which contains family statuses';
	
INSERT INTO family_statuses(name) VALUES
	('Single'),
	('Married');

ALTER TABLE profiles ADD COLUMN family_status_id INT UNSIGNED AFTER hometown;
UPDATE profiles SET family_status_id=FLOOR(1+(RAND()*2));

UPDATE users SET updated_at=created_at WHERE created_at<updated_at;
UPDATE profiles SET updated_at=created_at WHERE created_at<updated_at;
UPDATE profiles SET birthday=created_at WHERE birthday>created_at;

ALTER TABLE profiles MODIFY COLUMN user_id INT UNSIGNED NOT NULL UNIQUE;

DESC profiles;


CREATE TABLE messages (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	from_user_id INT UNSIGNED NOT NULL,
	to_user_id INT UNSIGNED NOT NULL,
	body TEXT NOT NULL,
	is_important BOOLEAN,
	is_delivered BOOLEAN,
	created_at DATETIME DEFAULT NOW()) COMMENT='Table which contains text messages exhchaged by users';


CREATE TABLE friendship (
	user_id INT UNSIGNED NOT NULL,
	friend_id INT UNSIGNED NOT NULL,
	status_id INT UNSIGNED NOT NULL,
	requested_at DATETIME DEFAULT NOW(),
	confirmed_at DATETIME,
	PRIMARY KEY (user_id, friend_id)) COMMENT='Table which contains frienship relations between users';



CREATE TABLE friendship_statuses (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(150) NOT NULL) COMMENT='Table which contains friendship status description';


CREATE TABLE communities (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(150) NOT NULL UNIQUE) COMMENT='Table which contains communities within the network';


CREATE TABLE communities_users (
	community_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (community_id, user_id)) COMMENT='Table which contains relations between communities and users';


CREATE TABLE media (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	media_type_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	file_name VARCHAR(255) NOT NULL,
	size INT NOT NULL,
	metadata JSON,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) COMMENT='Table which contains media';


CREATE TABLE media_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE) COMMENT='Table, which contains media-types';




select * from messages limit 15;

UPDATE messages set 
		from_user_id=FLOOR(1+(RAND()*1000)),
		to_user_id=FLOOR(1+(RAND()*1000));
	
UPDATE messages SET from_user_id=to_user_id+1 WHERE from_user_id=to_user_id;



UPDATE media_types SET name='audio' WHERE name='adipisci';
UPDATE media_types SET name='photo' WHERE name='aut';
UPDATE media_types SET name='video' WHERE name='occaecati';

DELETE FROM media_types;
TRUNCATE media_types;
INSERT INTO media_types(name) VALUES
	('photo'),
	('video'),
	('audio');


SELECT *FROM media_types;

SELECT * FROM media LIMIT 15;

UPDATE media SET user_id=FLOOR(1+(RAND()*500));

UPDATE media SET file_name=CONCAT('https://dropbox/vk/file_', `size`);

UPDATE media SET metadata=CONCAT('{"owner":"',(SELECT CONCAT(first_name, ' ',last_name) 
	FROM users WHERE id=user_id), '"}');

UPDATE media SET updated_at=created_at WHERE updated_at<created_at;


UPDATE friendship SET friend_id=FLOOR(1+(RAND()*500)), user_id=FLOOR(1+(RAND()*500));

UPDATE friendship SET requested_at=confirmed_at WHERE confirmed_at<requested_at;

SELECT*FROM friendship_statuses;

UPDATE friendship_statuses SET name='accepted' WHERE name='commodi';
UPDATE friendship_statuses SET name='rejected' WHERE name='veniam';
UPDATE friendship_statuses SET name='requested' WHERE name='quisquam';

TRUNCATE friendship_statuses;

INSERT INTO friendship_statuses(name) VALUES 
('Confirmed'),('Rejected'),('Requested');

	
ALTER TABLE media MODIFY COLUMN metadata JSON;
SELECT *FROM communities_users;

SELECT*FROM communities_users;


CREATE TABLE posts (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	user_id INT UNSIGNED NOT NULL,
	body TEXT NOT NULL,
	media_id INT UNSIGNED COMMENT 'Since it is not necessarily to have the media attached to posts, the column may take zero-values',
	like_id INT UNSIGNED COMMENT 'Since someone may like the post, I guess it should stand at the table. 
									The column may take zero-values, in case no one likes it',
	comment_id INT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()) 
	COMMENT ='Table, which contains info regarding posts';


CREATE TABLE comments (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	post_id INT UNSIGNED NOT NULL UNIQUE,
	user_id INT UNSIGNED NOT NULL,
	body TEXT NOT NULL,
	media_id INT UNSIGNED,
	like_id INT UNSIGNED COMMENT 'Since someone may like the comments made to the post, I guess it should stand at the table. 
							The column may take zero-values, in case no one likes it',
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW() ON UPDATE NOW())
	COMMENT ='Table, which contains comments to posts';

CREATE TABLE likes_users (
	like_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (like_id, user_id)) COMMENT ='Table, which contains relations between likes and users';
	
CREATE TABLE posts_likes (
	like_id INT UNSIGNED NOT NULL,
	post_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (like_id,post_id)) COMMENT ='Table, which contains relations between likes and posts';

CREATE TABLE comments_likes (
	like_id INT UNSIGNED NOT NULL,
	comment_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (like_id,comment_id)) COMMENT ='Table, which contains relations between likes and posts';
