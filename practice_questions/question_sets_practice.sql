/*-----------------
| Question Set #1 |
-----------------*/

/*
Question 1
We want to understand more about the movies that families are watching.
The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.

Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.

For this query, you will need 5 tables: Category, Film_Category, Inventory, Rental and Film.
HINT: One way to solve this is to create a count of movies using aggregations, subqueries and Window functions.
*/
select f.film_id, title, name
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music');


select f.film_id,
	   f.title,
	   count(*) rental_counts
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
group by 1,2
order by 2;

select f.film_id,
	   f.title,
	   count(*) over (partition by f.film_id order by f.title) rental_counts
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id;


--> this without window function
with t1 as
	(select f.film_id, title, name
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')),
t2 as
	(select f.film_id, f.title, count(*) rental_counts
	from film f
	join inventory i on i.film_id = f.film_id
	join rental r on r.inventory_id = i.inventory_id
	group by 1,2
	order by 2)
select t2.title film_title, t1.name category, t2.rental_counts rental_counts
from t2
join t1 on t1.film_id = t2.film_id
order by 2, 1;

--> this with window function
with t1 as
	(select f.film_id, title, name
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')),
t2 as
	(select f.film_id,
	   f.title,
	   count(*) over (partition by f.film_id order by f.title) rental_counts
	from film f
	join inventory i on i.film_id = f.film_id
	join rental r on r.inventory_id = i.inventory_id)
select distinct t2.title film_title, t1.name category, t2.rental_counts rental_counts
from t2
join t1 on t1.film_id = t2.film_id
order by 2, 1;
-----------------------------------------------

/*
Question 2
Now we need to know how the length of rental duration of these family-friendly movies
compares to the duration that all movies are rented for.

Can you provide a table with the movie titles and divide them into 4 levels
(first_quarter, second_quarter, third_quarter, and final_quarter) based on the
quartiles (25%, 50%, 75%) of the average rental duration(in the number of days) for movies across all categories?
Make sure to also indicate the category that these family-friendly movies fall into.

You should only need the category, film_category, and film tables to answer this and the next questions.
HINT: One way to solve it requires the use of percentiles, Window functions, subqueries or temporary tables.
*/

select f.film_id, title, name, rental_duration
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music');

select cast(round(avg(rental_duration),0) as integer) avg_duration
from film;


--> this
select *,
	   ntile(cast(round(avg(t1.rental_duration),0) as integer)) over (order by t1.rental_duration) standard_quartiles
from (select title, name, rental_duration
		from film f
		join film_category fc on f.film_id = fc.film_id
		join category c on c.category_id = fc.category_id
		where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1
group by 1, 2, 3
order by 4;

--> or that
select *,
	   ntile(4) over (order by t1.rental_duration) standard_quartiles
from (select title, name, rental_duration
		from film f
		join film_category fc on f.film_id = fc.film_id
		join category c on c.category_id = fc.category_id
		where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) t1;
-----------------------------------------------

/*
Finally, provide a table with the family-friendly film category, each of the quartiles,
and the corresponding count of movies within each combination of film category for each corresponding rental duration category.
The resulting table should have three columns:

Category
Rental length category
Count
*/

--> this
select name, standard_quartiles, count(*)
from (select name,
	   rental_duration,
	   ntile(4) over (order by rental_duration) standard_quartiles
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	where name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
	order by 1, 2)t1
group by 1, 2
order by 1, 2;
-----------------------------------------------

/*-----------------
| Question Set #2 |
-----------------*/

/*
Question 1:
We want to find out how the two stores compare in their count of rental orders
during every month for all the years we have data for.

Write a query that returns the store ID for the store, the year and month
and the number of rental orders each store has fulfilled for that month.
Your table should include a column for each of the following:
year, month, store ID and count of rental orders fulfilled during that month.
*/

select s.store_id,
	   left(cast(date_trunc('year', r.rental_date) as varchar), 4) rental_year,
	   substr(cast(date_trunc('month', r.rental_date) as varchar), 6, 2) rental_month,
	   s.store_id store_ID
from store s
join staff on staff.store_id = s.store_id
join rental r on r.staff_id = staff.staff_id;


--> this without window function
select *,
	   count(*) count_rentals
from (select substr(cast(date_trunc('month', r.rental_date) as varchar), 6, 2) rental_month,
	   		 left(cast(date_trunc('year', r.rental_date) as varchar), 4) rental_year,
	   		 s.store_id store_ID
		from store s
		join staff on staff.store_id = s.store_id
		join rental r on r.staff_id = staff.staff_id) t1
group by 1, 2, 3
order by 4 desc;

--> this with window function
select distinct *,
	   count(*) over (partition by store_ID, rental_year, rental_month) count_rentals
from (select substr(cast(date_trunc('month', r.rental_date) as varchar), 6, 2) rental_month,
	   		 left(cast(date_trunc('year', r.rental_date) as varchar), 4) rental_year,
	   		 s.store_id store_ID
		from store s
		join staff on staff.store_id = s.store_id
		join rental r on r.staff_id = staff.staff_id) t1
order by 4 desc;
-----------------------------------------------

/*
Question 2:
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007,
and what was the amount of the monthly payments.
Can you write a query to capture the customer name, month and year of payment,
and total payment amount for each month by these top 10 paying customers?
*/

select date_trunc('month', payment_date) paymon,
	   concat(first_name, ' ', last_name) full_name
from payment p
join customer c on p.customer_id = c.customer_id
where left(cast(date_trunc('month', payment_date) as varchar), 4) like '2007';

select customer_id,
	   sum(amount)
from payment
group by 1
order by 2 desc
limit 10;


--> this without window function
with t2 as
	(select customer_id,
	        sum(amount)
	from payment
	group by 1
	order by 2 desc
	limit 10)
select paymon,
	   full_name,
	   count(*) pay_countpermonth,
	   sum(t1.amount) pay_amount
from (select date_trunc('month', payment_date) paymon,
	   		 concat(first_name, ' ', last_name) full_name,
			 c.customer_id,
			 amount
		from payment p
		join customer c on p.customer_id = c.customer_id
		where left(cast(date_trunc('month', payment_date) as varchar), 4) like '2007') t1
join t2 on t2.customer_id = t1.customer_id
group by 1, 2
order by 1, 2, 4 desc;

--> this with window function
with t2 as
	(select customer_id,
	        sum(amount)
	from payment
	group by 1
	order by 2 desc
	limit 10)
select distinct paymon,
	   full_name,
	   count(*) over(partition by paymon, full_name) pay_countpermonth,
	   sum(t1.amount) over (partition by paymon, full_name) pay_amount
from (select date_trunc('month', payment_date) paymon,
	   		 concat(first_name, ' ', last_name) full_name,
			 c.customer_id,
			 amount
		from payment p
		join customer c on p.customer_id = c.customer_id
		where left(cast(date_trunc('month', payment_date) as varchar), 4) like '2007') t1
join t2 on t2.customer_id = t1.customer_id
order by 2, 1;
-----------------------------------------------

/*
Question 3
Finally, for each of these top 10 paying customers,
I would like to find out the difference across their monthly payments during 2007.

Please go ahead and write a query to compare the payment amounts in each successive month.
Repeat this for each of these 10 paying customers.
Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments.
*/

with t2 as
	(select customer_id,
	        sum(amount)
	from payment
	group by 1
	order by 2 desc
	limit 10)
select paymon,
	   full_name,
	   count(*) pay_countpermonth,
	   sum(t1.amount) pay_amount
from (select date_trunc('month', payment_date) paymon,
	   		 concat(first_name, ' ', last_name) full_name,
			 c.customer_id,
			 amount
		from payment p
		join customer c on p.customer_id = c.customer_id
		where left(cast(date_trunc('month', payment_date) as varchar), 4) like '2007') t1
join t2 on t2.customer_id = t1.customer_id
group by 1, 2
order by 2, 4 desc;

with t3 as
	(with t2 as
	(select customer_id,
	        sum(amount)
	from payment
	group by 1
	order by 2 desc
	limit 10)
select paymon,
	   full_name,
	   count(*) pay_countpermonth,
	   sum(t1.amount) pay_amount
from (select date_trunc('month', payment_date) paymon,
	   		 concat(first_name, ' ', last_name) full_name,
			 c.customer_id,
			 amount
		from payment p
		join customer c on p.customer_id = c.customer_id
		where left(cast(date_trunc('month', payment_date) as varchar), 4) like '2007') t1
join t2 on t2.customer_id = t1.customer_id
group by 1, 2
order by 2, 4 desc)
select paymon,
	   full_name,
	   pay_countpermonth,
	   pay_amount,
	   lag(pay_amount) over (partition by full_name order by paymon) lag_amount,
	   lead(pay_amount) over(partition by full_name order by paymon) as lead_amount,
	   lead(pay_amount) over(partition by full_name order by paymon) - pay_amount as lead_diff
from t3;


--> this without alias
with t2 as
	(select customer_id,
	        sum(amount)
	from payment
	group by 1
	order by 2 desc
	limit 10),
t3 as
	(select paymon,
		   full_name,
		   count(*) pay_countpermonth,
		   sum(t1.amount) pay_amount
	from (select date_trunc('month', payment_date) paymon,
		   		 concat(first_name, ' ', last_name) full_name,
				 c.customer_id,
				 amount
			from payment p
			join customer c on p.customer_id = c.customer_id
			where left(cast(date_trunc('month', payment_date) as varchar), 4) like '2007') t1
	join t2 on t2.customer_id = t1.customer_id
	group by 1, 2
	order by 2, 4 desc),
t4 as
	(select paymon,
		   full_name,
		   pay_countpermonth,
		   pay_amount,
		   lag(pay_amount) over (partition by full_name order by paymon) lag_amount,
		   lead(pay_amount) over(partition by full_name order by paymon) as lead_amount,
		   lead(pay_amount) over(partition by full_name order by paymon) - pay_amount as lead_diff
	from t3)
select paymon,
	   full_name,
	   lead_diff
from t4
where lead_diff = (select max(lead_diff) from t4);

--> with alias
with t2 as
	(select customer_id,
	        sum(amount)
	from payment
	group by 1
	order by 2 desc
	limit 10),
t3 as
	(select paymon,
		   full_name,
		   count(*) pay_countpermonth,
		   sum(t1.amount) pay_amount
	from (select date_trunc('month', payment_date) paymon,
		   		 concat(first_name, ' ', last_name) full_name,
				 c.customer_id,
				 amount
			from payment p
			join customer c on p.customer_id = c.customer_id
			where left(cast(date_trunc('month', payment_date) as varchar), 4) like '2007') t1
	join t2 on t2.customer_id = t1.customer_id
	group by 1, 2
	order by 2, 4 desc),
t4 as
	(select paymon,
		   full_name,
		   pay_countpermonth,
		   pay_amount,
		   lag(pay_amount) over alias_window lag_amount,
		   lead(pay_amount) over alias_window as lead_amount,
		   lead(pay_amount) over alias_window - pay_amount as lead_diff
	from t3
	window alias_window as
	(partition by full_name order by paymon))
select paymon,
	   full_name,
	   lead_diff
from t4
where lead_diff = (select max(lead_diff) from t4);


		