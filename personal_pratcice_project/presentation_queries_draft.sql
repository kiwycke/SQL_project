/*----------------------
| Presentation Queries |
----------------------*/

/*
Question 1:
How many times films in the family-friendly categories ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
were rented in each store?
*/

--> this without window function
select *,
	   count(*) count_rentals
from (select c.name, s.store_id
		from store s
		join staff on staff.store_id = s.store_id
		join rental r on r.staff_id = staff.staff_id
		join inventory i on i.inventory_id = r.inventory_id
		join film f on f.film_id = i.film_id
		join film_category fc on f.film_id = fc.film_id
		join category c on c.category_id = fc.category_id
		where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))t1
group by 1, 2
order by 1, 3 desc;

--> this with window function
select distinct *,
	   count(*) over (partition by t1.name, t1.store_id) count_rentals
from (select c.name, s.store_id
		from store s
		join staff on staff.store_id = s.store_id
		join rental r on r.staff_id = staff.staff_id
		join inventory i on i.inventory_id = r.inventory_id
		join film f on f.film_id = i.film_id
		join film_category fc on f.film_id = fc.film_id
		join category c on c.category_id = fc.category_id
		where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))t1
order by 1, 3 desc;
-----------------------------------------------


/*
Question 2
In the family-friendly film category ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
which was the top 3 most popular movies in 2005 by month and how many times were they rented out by month?
*/

select f.film_id, f.title, c.name,
	   left(cast(date_trunc('year', r.rental_date) as varchar), 4) rental_year,
	   substr(cast(date_trunc('month', r.rental_date) as varchar), 6, 2) rental_month
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	join inventory i on i.film_id = f.film_id
	join rental r on r.inventory_id = i.inventory_id
	where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music') and
		  left(cast(date_trunc('month', r.rental_date) as varchar), 4) like '2005';

select *,
	   count(*) count_rentals
from (select f.film_id, f.title, c.name,
			 left(cast(date_trunc('year', r.rental_date) as varchar), 4) rental_year,
	   		 substr(cast(date_trunc('month', r.rental_date) as varchar), 6, 2) rental_month
		from film f
		join film_category fc on f.film_id = fc.film_id
		join category c on c.category_id = fc.category_id
		join inventory i on i.film_id = f.film_id
		join rental r on r.inventory_id = i.inventory_id
		where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music') and
			  left(cast(date_trunc('month', r.rental_date) as varchar), 4) like '2005')t1
group by 1, 2, 3, 4, 5
order by 5, 6 desc;

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
-----------------------------------------------


/*
Question 3

How do customers distributed (quartiles and percentage) by district, among districts where we have at least 5 customers from?
*/


select c.customer_id, concat(first_name, ' ', last_name) full_name, a.district
from customer c
join address a on a.address_id = c.address_id;

with t1 as
	(select c.customer_id, concat(first_name, ' ', last_name) full_name, a.district
		from customer c
		join address a on a.address_id = c.address_id)
select t1.district,
	   count(*) customer_count
from t1
group by 1
having count(*) >= 5
order by 2 desc;


with t1 as
	(select c.customer_id, concat(first_name, ' ', last_name) full_name, a.district
		from customer c
		join address a on a.address_id = c.address_id),
t2 as
	(select t1.district,
	   		count(*) customer_count
		from t1
		group by 1
		having count(*) >= 5
		order by 2 desc)
select t2.district, t2.customer_count,
	   ntile(4) over (order by t2.customer_count) customer_quartile
from t2
order by 2 desc,3 desc;

--> this with window function
with t1 as
	(select c.customer_id, concat(first_name, ' ', last_name) full_name, a.district
		from customer c
		join address a on a.address_id = c.address_id),
t2 as
	(select t1.district,
	   		count(*) customer_count
		from t1
		group by 1
		having count(*) >= 5
		order by 2 desc)
select t2.district, t2.customer_count,
	   ntile(4) over (order by t2.customer_count) customer_quartile,
	   round((t2.customer_count/sum(t2.customer_count) over ())*100, 2) district_distribution
from t2
order by 2 desc,3 desc;
-----------------------------------------------


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






