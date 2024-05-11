
SELECT * FROM pizzahut.pizzas;

SELECT * FROM pizzahut.pizza_types;

SELECT * FROM pizzahut.orders;

SELECT * FROM pizzahut.order_details;

CREATE TABLE orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

CREATE TABLE order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

-- retrive total number of orders placed
SELECT COUNT(orders.order_id) AS Total_Orders
FROM pizzahut.orders;

-- Calculate the total revenue generated from pizza
SELECT 
ROUND(SUM(order_details.quantity * pizzas.price),2) AS Total_revenue
FROM order_details
JOIN pizzas 
ON order_details.pizza_id = pizzas.pizza_id;

-- identity the highest priced pizza
SELECT  pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price desc limit 1;

-- Identity most common pizza size ordered
SELECT quantity, count(order_details_id)
FROM pizzahut.order_details
group by quantity;

SELECT pizzas.size, COUNT(order_details.order_details_id) as order_count
FROM pizzas
JOIN order_details
ON pizzas.pizza_id= order_details.pizza_id
GROUP BY pizzas.size 
order by order_count DESC;

-- List the top most ordered pizza types along with their quantities
SELECT  pizza_types.name,  SUM(order_details.quantity ) as quantity
FROM pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by quantity desc
LIMIT 5;

-- join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(order_details.quantity) as quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantity desc;

-- determine the distrubution of orders by hour of the day
SELECT hour(order_time) as hours, COUNT(order_id) as order_count FROM orders
group by hour(order_time)
order by hours ASC;

-- category wise pizza
SELECT  count(name),category FROM pizza_types
group by category;

-- group the orders by date and calculate the average number of pizzaz ordered per day
SELECT orders.order_date, sum(order_details.quantity)
from orders 
JOIN order_details 
ON orders.order_id = order_details.order_id
group by orders.order_date;

-- Subquery |||
SELECT avg(quantity) from
(SELECT orders.order_date, sum(order_details.quantity) as quantity
from orders 
JOIN order_details 
ON orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue
SELECT pizza_types.name,sum(order_details.quantity*pizzas.price) as Revenue
FROM pizza_types
JOIN pizzas
ON pizzas.pizza_type_id= pizza_types.pizza_type_id
JOIN order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
limit 3 ;


-- calculate the percentage contribution of each pizza type to total revenue 
SELECT pizza_types.category,
round(sum(order_details.quantity* pizzas.price) / (SELECT 
ROUND(SUM(order_details.quantity * pizzas.price),2) AS Total_revenue
FROM order_details
JOIN pizzas 
ON order_details.pizza_id = pizzas.pizza_id)*100,2) as revenue
FROM pizza_types
JOIN pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category 
ORDER BY revenue DESC;

-- analyze the cumulative revenue generated over time.*********************************************************
select order_date,
sum(revenue) over(order by order_date) as cumulative_revenue
FROM
(SELECT orders.order_date,
sum(order_details.quantity*pizzas.price) as revenue
FROM order_details 
JOIN pizzas
ON order_details.pizza_id=pizzas.pizza_id
join orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as sales;

-- determine the top 3 most ordered pizza types based on revennue for each pizza category
SELECT name, revenue FROM
(SELECT category,name,revenue,
RANK() over(partition by category order by revenue desc) as rn
FROM
(SELECT pizza_types.category, pizza_types.name,
sum(order_details.quantity* pizzas.price) as revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name)
as a)
as b
WHERE rn <= 3 ;










