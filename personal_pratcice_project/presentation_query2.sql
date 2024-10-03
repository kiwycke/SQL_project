/*----------------------
| Presentation Queries |
----------------------*/

/*
Question 2
In the family-friendly film category ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
which was the top 3 most popular movies in 2005 by month and how many times were they rented out by month?
*/

--> this with window function
with t1 as
	(select f.film_id, f.title, c.name,
			 left(cast(date_trunc('year', r.rental_date) as varchar), 4) rental_year,
	   		 substr(cast(date_trunc('month', r.rental_date) as varchar), 6, 2) rental_month
		from film f
		join film_category fc on f.film_id = fc.film_id
		join category c on c.category_id = fc.category_id
		join inventory i on i.film_id = f.film_id
		join rental r on r.inventory_id = i.inventory_id
		where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music') and
			  left(cast(date_trunc('month', r.rental_date) as varchar), 4) like '2005'),
t2 as
	(select *,
	   		count(*) count_rentals
		from t1
		group by 1, 2, 3, 4, 5
		order by 5, 6 desc),
t3 as
	(select *,
		   row_number() over (partition by t2.rental_month) row_num
		from t2
		group by 1, 2, 3, 4, 5, 6
		order by 4, 5, 6 desc)
select *
from t3
where row_num = 1 or row_num = 2 or row_num = 3;