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
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
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


-- Решение задания вариант 2 - попытался поэкспериментировать с Concat, но запутался в скобках:
SELECT CONCAT(
(SELECT 
((SELECT sex 
	FROM profiles 
		WHERE user_id=likes.user_id)
			AS sex, 
				COUNT((SELECT sex 
					FROM profiles 
						WHERE user_id=likes.user_id)) as total_likes_by_sex
							FROM likes
								GROUP BY sex
									ORDER BY total_likes_by_sex DESC
										LIMIT 1) as sex), 'пол', 'поставил больше - ', (SELECT 
((SELECT total_likes_by_sex 
	FROM profiles 
		WHERE user_id=likes.user_id)
			AS sex, 
				COUNT((SELECT sex 
					FROM profiles 
						WHERE user_id=likes.user_id)) as total_likes_by_sex
							FROM likes
								GROUP BY sex
									ORDER BY total_likes_by_sex DESC
										LIMIT 1) as total_likes_by_sex), 'лайков') FROM  
((SELECT sex 
	FROM profiles 
		WHERE user_id=likes.user_id)
			AS sex, 
				COUNT((SELECT sex 
					FROM profiles 
						WHERE user_id=likes.user_id)) as total_likes_by_sex
							FROM likes
								GROUP BY sex
									ORDER BY total_likes_by_sex DESC
										LIMIT 1);



-- Найти 10 пользователей, которые проявляют наименьшую 
-- активность в использовании социальной сети.
-- Индикатором активности пользователя хотел сделать сумму значений объектов сущностей: 
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
            
   

                
				
	