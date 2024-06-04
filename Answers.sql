-- Q) Retrieve the total number of orders placed.
Select count(order_id) as total_sales from pizzasales.orders;

-- Q) Calculate the total revenue generated from pizza sales. 
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;

-- Q) Identify the highest-priced pizza.
SELECT 
    pizza_types.name AS highest_priced_pizza, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS Total_Orders_Count
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY Total_Orders_Count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name AS Pizza_names,
    SUM(orders_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY Pizza_names
ORDER BY Quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered. p1.category
SELECT 
    p1.category AS pizza_category,
    SUM(p3.quantity) AS total_quantity
FROM
    pizza_types p1
        JOIN
    pizzas p2 ON p1.pizza_type_id = p2.pizza_type_id
        JOIN
    orders_details p3 ON p3.pizza_id = p2.pizza_id
GROUP BY pizza_category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hour_of_the_Day,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY Hour_of_the_Day;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(pizza_types.pizza_type_id) AS Distribution
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS Daily_avg_pizzas
FROM
    (SELECT 
        o1.order_date, SUM(o2.quantity) AS quantity
    FROM
        orders o1
    JOIN orders_details o2 ON o1.order_id = o2.order_id
    GROUP BY o1.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    p1.name AS Pizza_names,
    SUM(p2.price * o1.quantity) AS revenue
FROM
    pizza_types p1
        JOIN
    pizzas p2 ON p1.pizza_type_id = p2.pizza_type_id
        JOIN
    orders_details o1 ON o1.pizza_id = p2.pizza_id
GROUP BY Pizza_names
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    p1.pizza_type_id AS Pizza_types,
    ROUND(SUM(p1.price * o1.quantity) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS total_revenue
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue_percentage
FROM
    pizzas p1
        JOIN
    orders_details o1 ON p1.pizza_id = o1.pizza_id
GROUP BY p1.pizza_type_id;


-- Analyze the cumulative revenue generated over time.
Select dates, round(sum(revenue) over (order by dates),2) as cum_revenue
from
	(SELECT 
    o1.order_date AS dates,
    SUM(o2.quantity * p1.price) AS revenue
FROM
    orders o1
        JOIN
    orders_details o2 ON o1.order_id = o2.order_id
        JOIN
    pizzas p1 ON p1.pizza_id = o2.pizza_id
GROUP BY dates) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, category, revenue from
(select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(SELECT 
    p1.name,
    p1.category,
    SUM(o1.quantity * p2.price) AS revenue
FROM
    pizza_types p1
        JOIN
    pizzas p2 ON p1.pizza_type_id = p2.pizza_type_id
        JOIN
    orders_details o1 ON o1.pizza_id = p2.pizza_id
GROUP BY p1.name , p1.category) as a ) as b
where rn<=3 ;

