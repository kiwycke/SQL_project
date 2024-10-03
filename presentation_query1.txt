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