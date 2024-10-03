select * from film;

select * from actor;

/*
Looks like you are ready to take on this PROJECT!
Everything you have been studying is going to come in handy now!

A quick note: You can ignore the "last_update" column in the tables,
as that column is part of the Sakila database but we will not be using it.
*/


/*------------------
| Practice Quiz #1 |
------------------*/

-- Let's start with creating a table that provides the following details:
-- actor's first and last name combined as full_name, film title, film description and length of the movie.
-- How many rows are there in the table? -> 5462
select concat(first_name, ' ', last_name) full_name, title, description, length
from actor a
join film_actor fa
on a.actor_id = fa.actor_id
join film f
on f.film_id = fa.film_id;

SELECT a.first_name, 
       a.last_name,
       a.first_name || ' ' || a.last_name AS full_name,
       f.title,
       f.length
FROM   film_actor fa
JOIN   actor a
ON     fa.actor_id = a.actor_id
JOIN   film f
ON     f.film_id = fa.film_id;

-- Write a query that creates a list of actors and movies where the movie length was more than 60 minutes.
-- How many rows are there in this query result? -> 4900
select concat(first_name, ' ', last_name) full_name, title, description, length
from actor a
join film_actor fa
on a.actor_id = fa.actor_id
join film f
on f.film_id = fa.film_id
where length > 60;

-- Write a query that captures the actor id, full name of the actor, and counts the number of movies each actor has made.
-- (HINT: Think about whether you should group by actor id or the full name of the actor.)
-- Identify the actor who has made the maximum number movies. -> Gina Degeneres
select a.actor_id, concat(first_name, ' ', last_name) full_name, count(*)
from actor a
join film_actor fa
on a.actor_id = fa.actor_id
join film f
on f.film_id = fa.film_id
group by 1, 2
order by 3 desc;

SELECT actorid, full_name, 
       COUNT(filmtitle) film_count_peractor
FROM
    (SELECT a.actor_id actorid,
	        a.first_name, 
            a.last_name,
            a.first_name || ' ' || a.last_name AS full_name,
            f.title filmtitle
    FROM    film_actor fa
    JOIN    actor a
    ON      fa.actor_id = a.actor_id
    JOIN    film f
    ON      f.film_id = fa.film_id) t1
GROUP BY 1, 2
ORDER BY 3 DESC;
-----------------------------------------------

-- Practice Quiz #2

-- Write a query that displays a table with 4 columns:
-- actor's full name, film title, length of movie, and a column name "filmlen_groups" that classifies movies based on their length.
-- Filmlen_groups should include 4 categories: 1 hour or less, Between 1-2 hours, Between 2-3 hours, More than 3 hours.
select first_name || ' ' || last_name as full_name, title,
		case
			when length <= 60 then '1 hour or less'
			when length > 60 and length <= 120 then 'Between 1-2 hours'
			when length > 120 and length <=180 then 'Between 2-3 hours'
			when length > 180 then 'More than 3 hours'
			else NULL
		end as filmlen_groups
from actor a
join film_actor fa
on a.actor_id = fa.actor_id
join film f
on f.film_id = fa.film_id
order by 3;

-- Academy Dinosaur -> 1-2, Color Philadelphia -> 2-3, Oklahoma Jumanji -> 1 or less
select full_name, title, filmlen_groups
from (select first_name || ' ' || last_name as full_name, title,
		case
			when length <= 60 then '1 hour or less'
			when length > 60 and length <= 120 then 'Between 1-2 hours'
			when length > 120 and length <=180 then 'Between 2-3 hours'
			when length > 180 then 'More than 3 hours'
			else NULL
		end as filmlen_groups
	from actor a
	join film_actor fa
	on a.actor_id = fa.actor_id
	join film f
	on f.film_id = fa.film_id
	order by 3) t1
where title like 'Academy Dinosaur%' or
	  title like 'Color Philadelphia' or
	  title like 'Oklahoma Jumanji'
group by 1,2,3
order by 2;

-- Now, we bring in the advanced SQL query concepts! Revise the query you wrote above to create a count of movies
-- in each of the 4 filmlen_groups:
-- 1 hour or less, Between 1-2 hours, Between 2-3 hours, More than 3 hours.

select distinct filmlen_groups, count(title) over (partition by filmlen_groups) as counts
from (select title, length,
		case
			when length <= 60 then '1 hour or less'
			when length > 60 and length <= 120 then 'Between 1-2 hours'
			when length > 120 and length <=180 then 'Between 2-3 hours'
			when length > 180 then 'More than 3 hours'
			else NULL
		end as filmlen_groups
	from film) t1
order by 1;

select distinct filmlen_groups, count(title) counts
from (select title, length,
		case
			when length <= 60 then '1 hour or less'
			when length > 60 and length <= 120 then 'Between 1-2 hours'
			when length > 120 and length <=180 then 'Between 2-3 hours'
			when length > 180 then 'More than 3 hours'
			else NULL
		end as filmlen_groups
	from film) t1
group by filmlen_groups
order by 1;

-----------------------------------------------