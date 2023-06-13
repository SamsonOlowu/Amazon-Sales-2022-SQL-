/* Amazon Sales 2022 - Data Cleaning 
Dataset Source: https://data.world/anilsharma87/sales
*/

Select *
from Projects.dbo.amazon_sales_2022
;

Select count(*)
from Projects.dbo.amazon_sales_2022
;
--128975 rows

---------------------------------------------------------
-- modify date_ type to date

alter table Projects.dbo.amazon_sales_2022
alter column date_ date

---------------------------------------------------------
-- Search for null values

select 
	sum(case when order_id is null then 1 else 0 end) as order_id,
	sum(case when index_ is null then 1 else 0 end) as index_,
	sum(case when date_ is null then 1 else 0 end) as date_,
	sum(case when status_ is null then 1 else 0 end) as status_,
	sum(case when fulfilment is null then 1 else 0 end) as fulfilment,
	sum(case when sales_channel is null then 1 else 0 end) as sales_channel,
	sum(case when ship_service_level is null then 1 else 0 end) as ship_service_level,
	sum(case when style is null then 1 else 0 end) as style,
	sum(case when sku is null then 1 else 0 end) as sku,
	sum(case when category is null then 1 else 0 end) as category,
	sum(case when size is null then 1 else 0 end) as size,
	sum(case when asin_ is null then 1 else 0 end) as asin_,
	sum(case when courier_status is null then 1 else 0 end) as courier_status,
	sum(case when qty is null then 1 else 0 end) as qty,
	sum(case when ship_city is null then 1 else 0 end) as ship_city,
	sum(case when ship_state is null then 1 else 0 end) as ship_state,
	sum(case when ship_postal_code is null then 1 else 0 end) as ship_postal_code,
	sum(case when promotion_ids is null then 1 else 0 end) as promotion_ids,
	sum(case when fulfilled_by is null then 1 else 0 end) as fulfilled_by,
	sum(case when b2b is null then 1 else 0 end) as b2b
from Projects.dbo.amazon_sales_2022

---------------------------------------------------------
-- Update courier_status

update Projects.dbo.amazon_sales_2022
set courier_status = 'Cancelled'
where courier_status is null and status_ = 'Cancelled';

update Projects.dbo.amazon_sales_2022
set courier_status = 'Shipped'
where courier_status is null and (status_ = 'Shipped - Delivered to Buyer' or status_ = 'Shipped - Returned to Seller')

---------------------------------------------------------
-- Update amount

update Projects.dbo.amazon_sales_2022
set amount = 0
where amount is null

---------------------------------------------------------
-- Update ship_city

select ship_city, count(*) as Total
from Projects.dbo.amazon_sales_2022
group by ship_city
order by ship_city;


update Projects.dbo.amazon_sales_2022
set ship_city = case
					when ship_city is null then 'Unknown' 
					when ship_city = ',HYDERABAD' then 'Hyderabad'
					when ship_city = ',raibarely road faizabad (Ayodhya)' then 'Ayodhya'
					when ship_city = '..katra' then 'Katra'
					when ship_city = '.Gannavaram' then 'Gannavaram'
					when ship_city = '(Via Cuncolim)Quepem,South Goa' then 'SOUTH - GOA'
					when ship_city = '(Chikmagalur disterict).     (N.R pur thaluku)' then 'Chikmagalur'
					when ship_city = '.azamgarh' then 'Azamgarh'
					when ship_city = '7BARASAT' then 'Barasat'
					when ship_city = '6th mile tadong' then 'Tadong'
					else ship_city
					end;



-- Remove '.' and ',' from ship_city

update Projects.dbo.amazon_sales_2022
set ship_city = substring(ship_city, 1, len(ship_city) -1)
where ship_city like '%.' or ship_city like '%,';

--Trim ship_city

update Projects.dbo.amazon_sales_2022
set ship_city = trim(ship_city)

-- Convert ship_city to Sentence case

update Projects.dbo.amazon_sales_2022
set ship_city = Upper(left(ship_city, 1)) + lower(substring(ship_city, 2, len(ship_city)))


---------------------------------------------------------
-- Update ship_state

update Projects.dbo.amazon_sales_2022
set ship_state = case 
					when ship_state is null then 'Unknown'
					when ship_state = 'Pondicherry' then 'Puducherry'
					when ship_state = 'Rajsthan' then 'Rajasthan'
					else ship_state
					end
					;

-- Convert ship_state to Sentence case

update Projects.dbo.amazon_sales_2022
set ship_state = Upper(left(ship_state, 1)) + lower(substring(ship_state, 2, len(ship_state)))

--Trim ship_state

update Projects.dbo.amazon_sales_2022
set ship_state = trim(ship_state)

select distinct(ship_state)
from Projects.dbo.amazon_sales_2022
order by ship_state
desc;

---------------------------------------------------------
-- Create 'promoted' and 'promotion' Columns

Alter Table Projects.dbo.amazon_sales_2022
add promoted BIT ;
Alter Table Projects.dbo.amazon_sales_2022
add promotion nvarchar(255) ;

-- Populate 'promoted' Column

update Projects.dbo.amazon_sales_2022
set promoted = 1
where promotion_ids is not null;
update Projects.dbo.amazon_sales_2022
set promoted = 0
where promotion_ids is null;

select  promoted,
	(case when promoted = 1 then 'True' else 'False' end)
	as promo
from Projects.dbo.amazon_sales_2022;

-- Populate 'promotion' Column

update a
set promotion = 'Amazon PLCC Free-Financing Universal Merchant'
from Projects.dbo.amazon_sales_2022 as a
join(
select promotion_ids
from Projects.dbo.amazon_sales_2022
group by promotion_ids
having promotion_ids like 'Amazon%'
) as b
on a.promotion_ids = b.promotion_ids;

update a
set promotion = 'IN Core Free Shipping'
from Projects.dbo.amazon_sales_2022 as a
join(
select promotion_ids
from Projects.dbo.amazon_sales_2022
group by promotion_ids
having promotion_ids like 'IN Core%'
) as b
on a.promotion_ids = b.promotion_ids;

update Projects.dbo.amazon_sales_2022
set promotion = case
					when promotion_ids like 'VPC%' then 'VPC Coupon'
					when promotion_ids like 'Duplicat%' then 'Duplicated'
					when promotion_ids is null then 'Not Promoted'
					else promotion_ids
					end
					;

select distinct(promotion)
from Projects.dbo.amazon_sales_2022;

---------------------------------------------------------
-- Populate null values in fulfilled_by column

Select distinct(fulfilled_by)
from Projects.dbo.amazon_sales_2022;

update Projects.dbo.amazon_sales_2022
set fulfilled_by = 'Others'
where fulfilled_by is null;

---------------------------------------------------------
-- check b2b

Select distinct(b2b)
from Projects.dbo.amazon_sales_2022;


---------------------------------------------------------
-- search duplicates

WITH CTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY order_id,
				 style,
				 date_,
				 status_,
				 sku,
				 qty,
				 amount,
				 asin_,
				 promotion,
				 ship_city,
				 ship_state
				 ORDER BY
					order_id desc
					) row_numb
from Projects.dbo.amazon_sales_2022
) 
select *
from CTE
where row_numb != 1

/*duplucates with row_numb 2 
index
79845
98955
30661
41292
86419
85791
*/

-- Delete duplicates

WITH CTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY order_id,
				 style,
				 date_,
				 status_,
				 sku,
				 qty,
				 amount,
				 asin_,
				 promotion,
				 ship_city,
				 ship_state
				 ORDER BY
					order_id desc
					) row_numb
from Projects.dbo.amazon_sales_2022
) 
DELETE
from CTE
where row_numb != 1
;

Select count(*)
from Projects.dbo.amazon_sales_2022
;

---------------------------------------------------------
-- Delete unused columns

alter table Projects.dbo.amazon_sales_2022
drop column sales_channel, currency, ship_postal_code, ship_country, promotion_ids, [Unnamed: 22];

Select *
from Projects.dbo.amazon_sales_2022
;