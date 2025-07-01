-- Monday_cofee


select * from city
select * from customers
select * from products
select * from sales

-- Report & Data Analysis


-- 1)Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT
	city_name ,
	(population * 25)/100 as consume_cofee
FROM city 
order by 2 desc


-- 2)Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select * from sales
select * from city

select 
	ct.city_name,
	sum(s.total) as total_revenue
from sales as s
join customers as c
on c.customer_id = s.customer_id
join city as ct
on ct.city_id = c.city_id
where
	extract (YEAR from sale_date ) = 2023
	and
	extract( quarter from sale_date) = 4
group by 1
order by 2 desc 

-- 3)Sales Count for Each Product
-- How many units of each coffee product have been sold?
select * from products
select * from sales

select 
	product_name,
	count(s.product_id) as total_sales
from products as p
join sales as s
on p.product_id = s.product_id
group by 1
order by 2 desc

--4) Average Sales Amount per City
-- What is the average sales amount per customer in each city?
select * from customers
select * from sales
select * from city 

select 
	ct.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as tota_cx,
	ROUND (sum(s.total) ::numeric/ 
					count(distinct s.customer_id):: numeric
					,2) as avg_sales_pr_cust
from sales as s
join customers as c
on c.customer_id = s.customer_id
join city as ct
on ct.city_id = c.city_id
group by 1
order by 2 desc;



-- 5) City Population and Coffee Consumers
--Provide a list of cities along with their populations and estimated coffee consumers.
select * from customers

select 
    c.city_name,
    c.population,
    count(cu.customer_id) as coffee_consumers
from 
    city c
join 
    customers cu on c.city_id = cu.city_id
group by  
    c.city_name, c.population
order by 
    coffee_consumers desc;



-- 6)Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
select * from city

select * 
from
	(select 
		ct.city_name,
		p.product_name,
		count(s.sale_id) as total_sales,
		dense_rank() over (partition by ct.city_name order by count(s.sale_id) desc ) as rank
	from products as p
	join sales as s
	on p.product_id = s.product_id
	join customers as c
	on s.customer_id = c.customer_id
	join city as ct
	on c.city_id = ct.city_id
	group by 1,2)
where rank <=3

-- 7)Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select 
	ct.city_name,
	count(distinct s.customer_id) as unique_cust
from sales as s
join customers as c
on c.customer_id = s.customer_id
join city as ct
on ct.city_id = c.city_id
where s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by 1
order by 2 desc



-- 8)Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

with city_table
as 
(
	select 
		c.city_name,
		count(distinct s.customer_id) as total_cust,
		sum(s.total),
		round( sum(s.total)::numeric/ 
							count(distinct s.customer_id)::numeric
							,2) as avg_sale_pr_cust
	from sales as s
	join customers as ct
	on s.customer_id = ct.customer_id
	JOIN city as c
	on ct.city_id = c.city_id
	group by 1
),
city_rent 
as 
(select 
	city_name,
	estimated_rent
from city
)
select
	ct.city_name,
	cr.estimated_rent,
	ct.total_cust,
	ct.avg_sale_pr_cust,
	round ( cr.estimated_rent ::numeric /
									ct.total_cust::numeric,2) as avg_rent
from city_table as ct
join city_rent as cr
on ct.city_name = cr.city_name
order by 4 desc

-- 9)Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

WITH
monthly_sales
AS
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM sale_date) as month,
		EXTRACT(YEAR FROM sale_date) as YEAR,
		SUM(s.total) as total_sale
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3, 2
),
growth_ratio
AS
(
		SELECT
			city_name,
			month,
			year,
			total_sale as cr_month_sale,
			LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
		FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	ROUND(
		(cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric * 100
		, 2
		) as growth_ratio

FROM growth_ratio
WHERE 
	last_month_sale IS NOT NULL	




-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


select 
    ci.city_name,
    sum(s.total) as total_sale,
    ci.estimated_rent as total_rent,
    count(DISTINCT s.customer_id) as total_customers,
    ROUND((ci.population * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
from sales s
join customers c on s.customer_id = c.customer_id
join city ci on c.city_id = ci.city_id
group by 
    ci.city_name, ci.estimated_rent, ci.population
order by 
    total_sale desc
limit 3;

FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC
