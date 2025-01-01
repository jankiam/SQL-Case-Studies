  -- Case Study Questions
SELECT 
    s.customer_id, SUM(price) AS Total_Amount_spent_by_customer
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
GROUP BY s.customer_id;
  
  
  -- 2. How many days has each customer visited the restaurant?
SELECT 
    customer_id, COUNT(DISTINCT (order_date)) AS Days_visited
FROM
    sales
GROUP BY customer_id;
  
  
  -- 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT
    customer_id, product_name
FROM
    sales
        JOIN
    menu ON menu.product_id = sales.product_id
WHERE
    order_date IN (SELECT 
            MIN(order_date)
        FROM
            sales
        GROUP BY customer_id);
  
  
  -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    product_name, COUNT(*) AS count_of_order
FROM
    sales
        JOIN
    menu ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY COUNT(*) DESC
LIMIT 1;
  
  
  -- 5. Which item was the most popular for each customer?

select customer_id, product_name from
(select customer_id, product_name, count(product_name) as count, dense_rank() OVER (partition by customer_id order by count(product_name) desc ) as num
from sales
join menu on menu.product_id=sales.product_id
group by customer_id, product_name
) as sub
where num=1;


-- 6. Which item was purchased first by the customer after they became a member?  
  With cte as(
select sales.customer_id, product_name, sales.product_id, order_date, dense_rank() OVER (partition by customer_id order by order_date asc) as num
from sales
join menu on menu.product_id=sales.product_id
join members on members.customer_id=sales.customer_id
where order_date>=join_date)
select customer_id,product_name from cte
where num=1;


-- 7. Which item was purchased just before the customer became a member?
With cte as(
select sales.customer_id, product_name, sales.product_id, order_date, dense_rank() OVER (partition by customer_id order by order_date DESC) as num
from sales
join menu on menu.product_id=sales.product_id
join members on members.customer_id=sales.customer_id
where order_date<join_date)
select customer_id, product_name from cte
where num=1;
  
  -- 8.  What is the total items and amount spent for each member before they became a member?
  
  
SELECT 
    m.customer_id,
    COUNT(s.product_id) AS total_items,
    SUM(price) AS total_amount
FROM
    members m
        JOIN
    sales s ON s.customer_id = m.customer_id
        JOIN
    menu me ON me.product_id = s.product_id
WHERE
    order_date < join_date
GROUP BY m.customer_id
ORDER BY m.customer_id;
  
  
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as(
select s.customer_id,m.product_name,
case when product_name='sushi' then m.price*10*2 
else m.price*10 end as points
from sales s
join menu m on m.product_id=s.product_id)
select customer_id, sum(points)
from cte
group by customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with cte as(
select s.customer_id, s.product_id, me.price, order_date,
case when order_date between join_date AND date_add(join_date, interval 7 day) then me.price*10*2
when product_name='sushi' then me.price*10*2
else me.price*10 end as points
from sales s
join members m on m.customer_id=s.customer_id
join menu me on me.product_id=s.product_id
where order_date <= '2021-01-31')
select customer_id, sum(points)
from cte
group by customer_id;


