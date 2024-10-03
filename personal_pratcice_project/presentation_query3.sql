/*----------------------
| Presentation Queries |
----------------------*/

/*
Question 3

How do customers distributed (quartiles and percentage) by district, among districts where we have at least 5 customers from?
*/

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