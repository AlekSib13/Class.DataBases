USE vk;
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- №1 Проанализировать какие запросы могут выполняться 
-- наиболее часто в процессе работы приложения и добавить необходимые индексы.
SHOW tables;
DESC comments;
DESC communities_users;
DESC friendship;
DESC likes;
DESC media;
DESC messages;
DESC posts;
DESC profiles;


CREATE INDEX friendship_requested_at_idx ON friendship(requested_at); 
-- Используется, например, когда мы собираем статистику по наиболее интенсивному времени (в разрезе суток, дней недели, месяцев), 
-- создания запросов на дружбу

CREATE INDEX media_created_at_idx ON media(created_at);
-- Используется, например, когда мы собираем статистику по наиболее интенсивному времени (в разрезе месяцев), 
-- загрузки контента на сервер. Информация необходима для планирования ресурсов серверов. Планирования обновлений 
-- (в данному случае потребуется статистика в разрезе времени суток)
CREATE INDEX media_updated_at_idx ON media(updated_at);
-- Используется в случаях аналогичных для предыдущего индекса

CREATE INDEX messages_created_at_messages_is_delivered_idx ON messages (created_at,is_delivered);
-- Используется, когда мы хотим поднять статистику по разнице между временем создания сообщения и временем доставки,
-- чтобы оценить скорость передачи сообщени через сервер (сервера). При условии, что created_at - время отпраки сообщения, 
-- а не время создания шаблона пользователем 

CREATE INDEX profiles_sex_profiles_birthday_idx ON profiles (sex,birthday);
-- Используется для сегментации пользователей по половому и возрастному признакам

CREATE INDEX profiles_sex_profiles_birthday_profiles_hometown_idx ON profiles (sex,birthday,hometown);
-- Используется для сегментации пользователей по половому, возрастному, территориальному признакам 

CREATE INDEX profiles_sex_profiles_birthday_profiles_family_status_id_profiles_hometown_idx ON profiles (sex,birthday,family_status_id,hometown);
-- Используется для сегментации пользователей по половому, возрастному,  семейному, территориальному признакам 


-- №2 Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый пожилой пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

SHOW tables;

SELECT*FROM communities_users;
DESC communities_users;
DESC communities;
DESC profiles;
DESC users;


SELECT DISTINCT
	co.name AS Group_name,
    COUNT(c_u.community_id) OVER (PARTITION BY co.name) AS Number_of_users_per_group,
    MAX(pr.birthday) OVER (PARTITION BY co.name) AS The_youngest_user_per_group,
	MIN(pr.birthday) OVER (PARTITION BY co.name) AS The_oldest_user_per_group,
    COUNT(pr.user_id) OVER () AS Total_number_of_users
    FROM users us
		JOIN profiles pr
			ON us.id=pr.user_id
	LEFT JOIN 
		communities_users c_u
        ON pr.user_id=c_u.user_id
	RIGHT JOIN 
		communities co
        ON c_u.community_id=co.id;

-- К сожалени, не все оконные функции получилось реализовать, например: 
-- при попытке посчитать общее количество пользователей в системе выводит значение 1662 , хотя их 498
-- см. реализацию отедльной оконной функции для подсчета количество пользователей:
SELECT
	COUNT(profiles.user_id) OVER() FROM profiles;
    
-- подозреваю, это происходит потому, что некоторые пользователи состоят в разных группах. При попытки вытащить 
-- только уникальные запросы через функцию 'COUNT(DISTINCT pr.user_id) OVER () AS Total_number_of_users',
-- mysql ругадается, что DISTINCT пока не поддерживается в оконных функциях.
-- Соответственно, также не удалось посчитать среднее количество пользователей в группах, а также отношение
-- количества пользователе в каждой группе к общему количеству пользователей


