-- Bài 3.1: Top 3 sản phẩm bán chạy nhất trong mỗi danh mục

	with tong_hang as (
		select 
		COALESCE(NULLIF(p.product_category_name, ''), 'chua_ro') AS product_category_name,
		p.product_id,
		count(*) as so_luong
		from order_items o
		join products p 
		on o.product_id  = p.product_id 
		group by COALESCE(NULLIF(p.product_category_name, ''), 'chua_ro'), p.product_id 
	), 
		xep_hang as(
		select 
		*,
		row_number() over (partition by product_category_name order by so_luong desc) as hang
		from tong_hang 
	)
		select 
		*
		from xep_hang 
		where hang <= 3
		order by product_category_name desc, hang asc
;

-- Bài 3.2: Doanh thu theo tháng, tháng kế tiếp (LEAD), lũy kế từ đầu năm (YTD)

with doanh_thu_thang as(
	select 
	DATE_TRUNC('month', o.order_purchase_timestamp) as Thang,
	DATE_TRUNC('year', o.order_purchase_timestamp) as nam,
	Coalesce(sum(op.payment_value), 0) as doanh_thu
	from orders o 
	left join order_payments op 
	on o.order_id = op.order_id where o.order_status = 'delivered'
	group by thang, nam
)
	select 
	thang,
	doanh_thu,
	lead(doanh_thu) over (order by thang) as doanh_thu_thang_sau,
	sum(doanh_thu) over (partition by nam order by thang) as luy_ke
	from doanh_thu_thang 
	order by thang asc;

-- Bài 3.3: Tính tổng lượng khách và số lượng khách quay lại + tỉ lệ

with so_luong_khach as (
	select 
	c.customer_unique_id,		
	count(*) as so_don
	from orders o 
	join customers c 
	on o.customer_id  = c.customer_id 
	where o.order_status = 'delivered'
	group by c.customer_unique_id
)
	select
	count(so_don) as tong_khach,
	count(so_don ) filter (where so_don  >=2) as khach_quay_lai,
	round(100.0*count(so_don ) filter (where so_don  >1)/count(so_don), 2) as ti_le_quay_lai_pct
	from so_luong_khach  
	order by tong_khach desc;

EXPLAIN analyze
select 
*
from orders
where customer_id = '8ab97904e6daea8866dbdbc4fb7aad2c';

CREATE INDEX tim_khach_hang ON orders (customer_id) ;

-- bài 3.3b tìm số lần khách hàng mua lại và trung bình thời gian mua lại

	with don_hang as (
	select 
	c.customer_unique_id,		
	o.order_purchase_timestamp::date as ngay_dat_don
	from orders o 
	join customers c 
	on o.customer_id  = c.customer_id 
	where o.order_status = 'delivered'
), 
	don_truoc as (
	select 
	customer_unique_id,
	ngay_dat_don,
	lag(ngay_dat_don) over (partition by customer_unique_id order by ngay_dat_don) as ngay_truoc
	from don_hang  
)
	select 
	count(*) as so_lan_quay_lai,
	round(AVG(ngay_dat_don - ngay_truoc), 1) as trung_binh_thoi_gian
	from don_truoc
	where ngay_truoc is not null;
