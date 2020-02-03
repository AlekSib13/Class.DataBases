USE vk;
DESC users;
DESC profiles;
SELECT first_name, last_name, 'main_photo','city' FROM users WHERE id=3;

SELECT
first_name, last_name, 
	(SELECT file_name FROM media WHERE id= 
		(SELECT photo_id FROM profiles WHERE user_id=users.id)) AS filename,
	(SELECT hometown FROM profiles WHERE user_id=users.id) AS hometown
FROM users WHERE id=3;

DESC media;
DESC media_types;

SELECT CONCAT('Пользователь', ' ',
(SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id=media.user_id), ' ',
'добавил фото',' ', file_name,
' ', created_at) file_name FROM media 
	WHERE  user_id=3 
    AND media_type_id=
		(SELECT id FROM media_types WHERE name='photo');

DESC media;
SELECT 
(SELECT CONCAT(first_name, ' ', last_name) 
	FROM users u
		WHERE u.id=m.user_id) owner,
	file_name, 
    size 
	FROM media m 
    ORDER BY size DESC 
    LIMIT 10;
    
 SELECT user_id, SUM(size) AS total 
	FROM media
		GROUP BY user_id
			HAVING total>100000000
				ORDER BY total DESC;




-- HOMEWORK
-- №2                
-- Пусть задан некоторый пользователь. 
-- �?з всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
-- Рассмотрел задачу в значении - отправлял больше всего сообщений нашему пользователю 

DESC friendship;
SELECT*FROM friendship;
SELECT *FROM friendship_statuses;
DESC messages;

INSERT INTO messages (from_user_id, to_user_id, body,is_delivered) VALUES
	(50,269,'fhfhhfhfhfh',1),
    (269,50,'fkfkkfkfjsjjds',1),
    (50,269,'fkfkwldewldewkdwe',1),
    (50,269,'dsajknjqw ehqwdyw',1),
  	(42,50,'dfhfhhfhfhfh',1),
    (42,50,'fkfkkfkfjsjjds',1),
    (50,42,'fkfkwldewldewkdwe',1),
    (42,50,'dsajknjqw ehqwdyw',1);


SELECT to_user_id, from_user_id, COUNT(*) AS the_most_frequent_sender
	FROM messages 
		WHERE to_user_id=	
        ((SELECT user_id
			FROM friendship 
				WHERE user_id=50 AND status_id =
					(SELECT id FROM friendship_statuses WHERE name='Confirmed'))
	UNION
		(SELECT friend_id 
			FROM friendship 
				WHERE friend_id=50 AND status_id=
					(SELECT id FROM friendship_statuses WHERE name='Confirmed')))
		GROUP BY from_user_id
        ORDER BY the_most_frequent_sender DESC
        LIMIT 1;
        
-- Пришлось применить функцию ниже, чтобы избавится от сообщения 'ONLY_FULL_GROUP_BY'
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));


-- №3. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
-- Решил использовать возраст пользователей более или равно 10 лет, что бы выглядело более менее логично (когда ребенок умеет читать и писать)
-- Аналогично предыдущему заданию: пришлось 
-- применить функцию ниже SET GLOBAL..., чтобы избавится от сообщения 'ONLY_FULL_GROUP_BY'. 
-- В случае, если при запуске mysql этот метод не был запущен ранее. 
-- Подскажите, пожалуйста, способ отключения ONLY_FULL_GROUP_BY на постоянной основе.

SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT *FROM likes;
DESC users;
DESC profiles;

SHOW TABLES;




SELECT SUM(total_likes) FROM (SELECT COUNT(*) as total_likes
	FROM likes 
		WHERE user_id IN
			(SELECT user_id 
				FROM profiles
					WHERE TIMESTAMPDIFF(YEAR,birthday,NOW())>=10 
						ORDER BY TIMESTAMPDIFF(YEAR,birthday,NOW()))
                        GROUP BY user_id
                        LIMIT 10) AS counted_likes;
 
 -- Виктор, спасибо за помощь со сриптом.
 -- Поповоду вашего комментария:
 -- 	"Но обратите внимание что при таком подходе у вас из расчёта 
 -- 	выпадут пользователи с нулевым количеством лайков".
 -- -Но у меня в скрипте ничто не указывает, на то, что пользователи с 0 лайками пропускаются
 
 
 -- №4. Определить кто больше поставил лайков (всего) - мужчины или женщины?
-- Аналогично предыдущему заданию: пришлось 
-- применить функцию ниже SET GLOBAL..., чтобы избавится от сообщения 'ONLY_FULL_GROUP_BY'. 
-- В случае, если при запуске mysql этот метод не был запущен ранее. 
-- Подскажите, пожалуйста, способ отключения ONLY_FULL_GROUP_BY на постоянной основе.
 
 SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
 
 DESC profiles;
 DESC likes;
 SELECT user_id, sex 
	FROM profiles;
    
SELECT user_id, target_id 
	FROM likes;


-- Решение задания, вариант 1:
SELECT 
(SELECT sex 
	FROM profiles 
		WHERE user_id=likes.user_id)
			AS sex, 
				COUNT((SELECT sex 
					FROM profiles 
						WHERE user_id=likes.user_id)) as total_likes_by_sex
							FROM likes
								GROUP BY sex
									ORDER BY total_likes_by_sex DESC
										LIMIT 1;




-- Найти 10 пользователей, которые проявляют наименьшую 
-- активность в использовании социальной сети.
-- �?ндикатором активности пользователя хотел сделать сумму значений объектов сущностей: 
-- сообщения от пользователей, лайки, медиа-контент. Однако сумел составить только резюмирующую таблицу
-- по каждому пользователю. Не догадался, как проести построчное суммирование. Прошу помочь.
 
-- - по каждому пользователю,чтобы 
-- объект каждой сущности приравниваем к 1 и суммируем по Пользователю
-- Аналогично предыдущему заданию: пришлось 
-- применить функцию ниже SET GLOBAL..., чтобы избавится от сообщения 'ONLY_FULL_GROUP_BY'. 
-- В случае, если при запуске mysql этот метод не был запущен ранее. 
-- Подскажите, пожалуйста, способ отключения ONLY_FULL_GROUP_BY на постоянной основе.
 
 SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

DESC messages;
DESC likes;
DESC media;
                                

-- Виктор, также попытался экранировать апостроф, например user's, однако, 
-- mysql выдает ошибку синтаксиса при обоих вариантах экранирования:
-- вариант 1: \'
-- вариант 2:. "'" 

SELECT user_id, COUNT(user_id) AS number_of_likes_from_user,
	(SELECT COUNT(from_user_id)
		FROM messages
			WHERE id=likes.user_id
				GROUP BY from_user_id) AS number_of_messages_from_user,
	(SELECT COUNT(user_id)
		FROM media
			WHERE id=likes.user_id
				GROUP BY user_id) AS number_of_media_from_user
		FROM likes
			GROUP BY user_id;
  

		


UPDATE likes SET target_id_type=FLOOR(1+(RAND()*4));		

SHOW tables;
SELECT*FROM users;
SELECT *FROM posts;
SELECT *FROM media WHERE user_id=15;
SELECT*FROM likes WHERE user_id=15 AND target_id_type=3;
SELECT*FROM media_types;
DESC posts;
SELECT*FROM comments;

INSERT INTO posts (user_id,body,media_id,like_id,comment_id) VALUES
	(15,'fjjfhjskncjksnckwln',714,93,1);
  
		
		
-- HW8
-- 1. �������� ����������� ������� ����� ��� ���� ������ ���� ������ vk (��������� �������).
USE vk

SHOW tables;
DESC comments;
DESC friendship;
DESC likes;
DESC media;
DESC messages;
DESC posts;
DESC profiles;


SELECT *FROM media;


SELECT*FROM target_types;


ALTER TABLE comments 
	ADD CONSTRAINT comments_post_id_fk
		FOREIGN KEY (post_id) REFERENCES posts(id)
			ON DELETE CASCADE, 
	ADD CONSTRAINT comments_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT comments_media_id_fr
		FOREIGN KEY (media_id) REFERENCES media(id)
			ON DELETE CASCADE;

		
		
ALTER TABLE friendship 
	ADD CONSTRAINT friendship_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,	
	ADD CONSTRAINT friendship_friend_id_fk
		FOREIGN KEY (friend_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT friendship_status_id_fk
		FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
			ON DELETE RESTRICT
			ON UPDATE CASCADE;

		
		
ALTER TABLE likes 
	ADD CONSTRAINT likes_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT likes_target_id_fk_users
		FOREIGN KEY (target_id) REFERENCES users(id)
			ON DELETE CASCADE,		
	ADD CONSTRAINT likes_target_id_fk_messages
		FOREIGN KEY (target_id) REFERENCES messages(id)
			ON DELETE CASCADE,		
	ADD CONSTRAINT likes_target_id_fk_med
		FOREIGN KEY (target_id) REFERENCES media(id)
			ON DELETE CASCADE, 
	ADD CONSTRAINT likes_target_id_fk_tp
		FOREIGN KEY (target_id_type) REFERENCES target_types(id)
			ON UPDATE CASCADE
			ON DELETE RESTRICT;


-- � ��������� �� ������ ������� ����� ������. ��� ������������: 
-- ������������ ��� ����� � �������� ��������, ��� ����� ����������� ������.
ALTER TABLE likes
	ADD CONSTRAINT likes_target_id_fk_posts
		FOREIGN KEY (target_id) REFERENCES posts(id)
			ON DELETE CASCADE;		
--- 				


ALTER TABLE media 
	ADD CONSTRAINT media_type_id_fk
		FOREIGN KEY (media_type_id) REFERENCES media_types(id)
			ON UPDATE CASCADE
			ON DELETE RESTRICT,
	ADD CONSTRAINT media_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE;



ALTER TABLE messages
	ADD CONSTRAINT messages_from_user_id_fk
		FOREIGN KEY (from_user_id) REFERENCES users(id),
	ADD CONSTRAINT messages_to_user_id_dk
		FOREIGN KEY (to_user_id) REFERENCES users(id);
		


ALTER TABLE posts
	ADD CONSTRAINT posts_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id),
	ADD CONSTRAINT posts_media_id_fk
		FOREIGN KEY (media_id) REFERENCES media(id)
		ON DELETE CASCADE;


ALTER TABLE profiles
	ADD CONSTRAINT profiles_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT profiles_family_status_id_fk
		FOREIGN KEY (family_status_id) REFERENCES family_statuses(id)
			ON UPDATE CASCADE
			ON DELETE SET NULL,
	ADD CONSTRAINT profiles_photo_id_fk
		FOREIGN KEY (photo_id) REFERENCES media(id)
			ON DELETE SET NULL
			ON UPDATE CASCADE;

DESC communities_users;



ALTER TABLE communities_users
		ADD CONSTRAINT communities_users_community_id_fk
			FOREIGN KEY (community_id) REFERENCES communities(id)
				ON DELETE CASCADE,
		ADD CONSTRAINT communities_users_user_id_fk
			FOREIGN KEY (user_id) REFERENCES users(id)
				ON UPDATE CASCADE;



