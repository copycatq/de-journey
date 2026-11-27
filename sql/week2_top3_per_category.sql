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