WITH items_theo_don AS (
    SELECT order_id, COUNT(*) AS so_san_pham
    FROM order_items
    GROUP BY order_id                -- giờ đây 1 dòng = 1 đơn
),
	tien_theo_don AS (
	    select 
	    order_id,
	    sum(payment_value) as so_tien_don
	    from order_payments 
	    group by order_id 
)
select
c.customer_state,
sum(it.so_san_pham ) as so_san_pham,
count(*) as so_don,
round(sum(t.so_tien_don)::numeric, 2) as doanh_thu
FROM orders o
JOIN customers c        on o.customer_id  = c.customer_id 
JOIN items_theo_don it  ON o.order_id = it.order_id 
JOIN tien_theo_don t    ON o.order_id = t.order_id 
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
order by doanh_thu desc;