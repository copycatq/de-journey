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
