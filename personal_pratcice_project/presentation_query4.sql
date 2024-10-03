/*----------------------
| Presentation Queries |
----------------------*/

/*
Question 4

Which are the 10 most expensive and 10 cheapest movies? How many times were they rented out in 2005?
*/

with t1 as
	(select *
	from (select film_id, title, replacement_cost
			from film
			order by 3 desc, 2
			limit 10)t1
	union
	select *
	from (select film_id, title, replacement_cost
			from film
			order by 3, 2
			limit 10)t1)
select distinct t1.film_id, t1.title, t1.replacement_cost,
	   left(cast(date_trunc('year', r.rental_date) as varchar), 4) rental_year,
	   count(*) over (partition by t1.film_id) rental_count
from t1
join inventory i on i.film_id = t1.film_id
join rental r on r.inventory_id = i.inventory_id
where left(cast(date_trunc('month', r.rental_date) as varchar), 4) like '2005'
order by 3 desc, 5 desc;


/*
-- checking why is the movie 'Deliverance Mulholland' with film_id: 221 is missing from the results of cheapest movies
select *
from (select film_id, title, replacement_cost
		from film
		order by 3 desc, 2
		limit 10)t1
union
select *
from (select film_id, title, replacement_cost
		from film
		order by 3, 2
		limit 10)t1
order by 3 desc, 2;
		
select distinct f.film_id, f.title, 
	   count(*) over (partition by f.film_id) rental_count
from film f
join inventory i on i.film_id = f.film_id
where f.film_id between 220 and 222;
*/