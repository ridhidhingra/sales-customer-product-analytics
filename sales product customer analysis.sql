
-- SELECT * FROM dbanalysis.sales_info;
-- SELECT * FROM dbanalysis.prdss_info
-- SELECT * FROM dbanalysis.cust_infoo
-- use dbanalysis



#1 find the date of first and last order 
-- select min(sls_order_dt) as lastdate,
-- max(sls_order_dt) as firstdate ,
-- TIMESTAMPDIFF(month,min(sls_order_dt),max(sls_order_dt)) as date_range 
-- from sales_info



-- #2 find total no of sales
-- select sum(sls_sales) from sales_info as total_sales
#3 how many item are sold
-- select
-- count(sls_quantity)as nuber_of_item from sales_info 

#4 average selling price 
-- select
-- avg(sls_price) as average from sales_info 

#5 total number of order
-- select
-- count(distinct sls_order_dt) from sales_info  as number


#6 total numer of product
-- select
-- count(prd_nm) as total_number_prd from prdss_info

#7 total numer of customer
-- select
-- count(cst_id) as total_numb_cust from cust_infoo

-- #8 total no of customer placed order 
-- select
-- count(distinct sls_cust_id) as total_customer from sales_info


-- #9 generate a business report 
-- select 'total sales' as measure_name,sum(sls_sales) as measure_value from sales_info
-- union all
-- select 'number of item sold' as measure_name,count(sls_quantity) as measure_value from sales_info
-- union all
-- select 'average price' ,avg(sls_price) from sales_info
-- union all
-- select 'total number of order',count(distinct sls_order_dt) from sales_info
-- union all
-- select 'number of product',count(prd_nm)  from prdss_info
-- union all
-- select 'total number of customer',count(cst_id)  from cust_infoo


-- -------different cases--------

# case1 analysis sales performance overtime 
-- select year(sls_order_dt) as years,
-- sum(sls_sales) as total_sales,
-- sum(sls_quantity) as qnty,
-- count(distinct sls_cust_id) as numberbcustomer
-- from sales_info
-- group by year(sls_order_dt)
-- order by year(sls_order_dt) desc

-- select date_format(sls_order_dt,'%Y-%m') as monthyears,
-- sum(sls_sales) as total_sales,
-- sum(sls_quantity) as quantity,
-- count(distinct sls_cust_id) as number_customer
-- from sales_info
-- group by  date_format(sls_order_dt,'%Y-%m')
-- order by  date_format(sls_order_dt,'%Y-%m') desc

# case 2 total sales per month overtime 
-- select 
-- sls_order_dt,total_revenue,
-- sum(total_revenue) over(order by sls_order_dt desc)as cf
-- from 
-- 	(select sls_order_dt,
-- 	sum(sls_sales) as total_revenue
-- 	from sales_info
-- 	group by sls_order_dt
-- 	order by sls_order_dt)t 
--     
-- select 
-- mn,total_revenue,
-- sum(total_revenue) over(order by mn desc)as cf
-- from 
-- 	(select month(sls_order_dt)as order_month,
-- 	sum(sls_sales) as total_revenue
-- 	from sales_info
-- 	group by month(sls_order_dt)
-- 	order by month(sls_order_dt))t


-- #  case3 yearly performance of product by comparing their sales toboth the average sales of product and previous year sales  
-- with current_product_sales as
-- (select 
-- year(s.sls_order_dt) as yearlysales,
-- sum(s.sls_sales) as current_sales,p.prd_nm
-- from sales_info as s
-- left join prdss_info as p
-- on s.sls_prd_key=p.prd_key
-- where p.prd_nm is not null
-- group by 
-- year(s.sls_order_dt),p.prd_nm)
-- select yearlysales,
-- current_sales,
-- prd_nm,
-- avg(current_sales) over (partition by prd_nm)as average_sales,
-- current_sales-avg(current_sales) over (partition by prd_nm)as average_diff,
-- case 
-- 	when current_sales-avg(current_sales) over (partition by prd_nm) >0 then'above average'
-- 	when current_sales-avg(current_sales) over (partition by prd_nm) <0 then'below average'
-- 	else 'average '
-- end as average_change,
-- lag(current_sales) over (partition by prd_nm) as previous_sales,
-- case
-- 	when current_sales-lag(current_sales) over (partition by prd_nm)>0 then 'increase'
--     when current_sales-lag(current_sales) over (partition by prd_nm)<0 then 'decrease'
--     else 'normal'
-- end as previous_average_change
-- from current_product_sales
-- order by yearlysales ,prd_nm



#case4 which category contribute the most 
-- with product_average_sales as
-- (select 
-- p.prd_nm,
-- sum(s.sls_sales) as product_sales
-- from sales_info as s
-- left join prdss_info as p
-- on s.sls_prd_key=p.prd_key
-- where p.prd_nm is not null
-- group by 
-- p.prd_nm
-- order by product_sales desc)
-- select
-- product_sales,
-- prd_nm,
-- sum(product_sales) over() as overall_sales,
-- concat(round((product_sales/sum(product_sales) over())*100,2),'%')as percentage_contribute
-- from product_average_sales

-- #  case5 group customer into three segmentbased on their spending behaviour

-- with customer_segment as
-- (select 
-- cst_id,
-- sum(s.sls_sales) as product_sales,
-- min(sls_order_dt) as first_order,
-- max(sls_order_dt) as last_order,
-- timestampdiff(month,min(sls_order_dt),max(sls_order_dt)) as lifespan
-- from sales_info as s
-- left join cust_infoo as c
-- on s.sls_cust_id=c.cst_id
-- group by 
-- cst_id
-- order by product_sales desc)

-- select segments,count(cst_id) as totalcust
-- from
-- (select cst_id,
-- product_sales,
-- lifespan,
-- case when product_sales>5000 and lifespan>=12 then 'VIP'
-- 	 when product_sales<=5000 and lifespan>=12 then 'regular'
-- 	else 'new'
-- end as segments
-- from customer_segment) t
-- group by segments
-- order by totalcust desc


# case6 customer bussiness report
-- with customer_query as
-- (select 
-- sls_ord_num,sls_prd_key,sls_order_dt,sls_quantity,sls_sales,cst_id,
-- timestampdiff(year,cst_birthdate,curdate()) as age ,
-- concat(cst_firstname,'', cst_lastname)as full_name
-- from sales_info as s
-- left join cust_infoo as c
-- on s.sls_cust_id=c.cst_id), 

-- customer_report as (select
-- cst_id,full_name,
-- age,sum(sls_quantity) as total_quantity,
-- sum(sls_sales) as product_sales,
-- count(sls_ord_num) as total_orders,
-- count(sls_prd_key) as total_product,
-- min(sls_order_dt) as first_order,
-- max(sls_order_dt) as last_order,
-- timestampdiff(month,min(sls_order_dt),max(sls_order_dt)) as lifespan
--  from customer_query
-- group by cst_id,full_name,age)

-- select
-- cst_id,full_name,
-- age,
-- case when age<20 then'below 20'
-- 	when age between 20 and 29 then'20-29'
--     when age between 30 and 39 then'30-39'
--     when age between 40 and 49 then'40-49'
--     else 'aboe50'
--     end as age_group,
-- case when product_sales>5000 and lifespan>=12 then 'VIP'
-- 	 when product_sales<=5000 and lifespan>=12 then 'regular'
-- 	else 'new'
-- end as customer_segments,
--  total_quantity,
--  product_sales,
-- total_orders,
--  total_product
--  from customer_report

