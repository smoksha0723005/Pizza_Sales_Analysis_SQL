-- -------------------------------- PIZZA SALES ANALYSIS ----------------------------------------
-- Q1. RETRIEVE TOTAL NUMBER OF ORDERS PLACED
select count(*) as total_orders
from orders;

-- Q2. CALCULATE TOTAL REVENUE GENERATED FROM PIZZA SALES
select 
concat(round(sum(order_details.quantity * pizzas.price)/1000,2), "K") as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;

-- Q3. IDENTIFY THE HIGHEST PRICED PIZZA
select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;

-- Q4. IDENTIFY THE MOST COMMON PIZZA SIZE ORDERED 
select pizzas.size, count(order_details.order_details_id) as total_orders
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by total_orders desc;

-- Q5. LIST THE 5 MOST ORDERED PIZZA TYPE ALONG WITH THEIR QUANTITIES
select pt.name, sum(od.quantity) as total_quantity
from pizza_types pt 
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.name
order by total_quantity desc
limit 5;

-- Q6. JOIN THE NECESSARY TABLES TO FIND THE TOTAL QUANTITY OF EACH PIZZA CATEGORY
select pt.category,
sum(od.quantity) as quantity
from pizza_types pt 
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.category
order by quantity desc
limit 5;

-- Q7. DETERMINE THE DISTRIBUTION OF ORDER BY HOUR OF THE DAY
select hour(order_time) as hour_of_the_day, count(order_id) as order_count
from orders
group by hour_of_the_day
order by order_count desc;

-- Q8. JOIN RELEVANT TABLES TO FIND THE CATEGORY WISE DISTRIBUTION OF PIZZAS
select category, count(name)
from pizza_types
group by category
order by count(name);

-- Q9. GROUP THE ORDERS BY DATE AND CALCULATE THE AVERAGE NUMBER OF PIZZAS ORDERED PER DAY
select round(avg(quantity),0) as avg_quantity
from
(select o.order_date, sum(od.quantity) as quantity
from orders o 
join order_details od
on o.order_id = od.order_id
group by o.order_date) as order_quantity;

-- Q10. DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON THE REVENUE
select pt.name, 
sum(od.quantity * p.price) as total_revenue
from pizza_types pt
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.name
order by total_revenue desc
limit 3;

-- Q11. DETERMINE THE TOP 3 MOST ORDERED PIZZA CATEGORY BASED ON THE REVENUE
select pt.category, 
round(sum(od.quantity * p.price), 2) as total_revenue
from pizza_types pt
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on p.pizza_id = od.pizza_id
group by pt.category
order by total_revenue desc
limit 3;

-- Q12. ANALYZE THE CUMULATIVE REVENUE GENERATED OVER TIME
select order_date,
round(sum(total_revenue) over(order by order_date), 2) as cum_revenue
from 
(select o.order_date, 
sum(od.quantity * p.price) as total_revenue
from order_details od
join pizzas p 
on od.pizza_id = p.pizza_id
join orders o 
on o.order_id = od.order_id
group by o.order_date) as sales;

-- Q13. DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES ON REVENUE FOR EACH PIZZA CATEGORY
select category, name, total_revenue, revenue_rank
from
(
select category, name, total_revenue, 
rank() over(partition by category order by total_revenue desc) as revenue_rank
from
(select pt.category, pt.name, 
sum(od.quantity * p.price) as total_revenue
from pizza_types pt
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by pt.category, pt.name
) as sales
) as b
where revenue_rank <= 3;
