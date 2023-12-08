select * 
from [dbo].[sales_data]

select distinct [STATUS] from [dbo].[sales_data] --factor 
select distinct [YEAR_ID] from [dbo].[sales_data] --factor 
select distinct [PRODUCTLINE] from [dbo].[sales_data] --factor
select distinct [COUNTRY] from [dbo].[sales_data] --factor
select distinct [DEALSIZE] from [dbo].[sales_data] --factor

--total trx 2823 with 92 customer 
select COUNT(*) as total_trx
from [dbo].[sales_data]

select COUNT(distinct [CUSTOMERNAME]) as total_trx
from [dbo].[sales_data]
---
select SUM(sales)as total_sales,[STATUS] 
from [dbo].[sales_data] --factor 
group by STATUS
order by total_sales desc


select SUM(sales)as total_sales,DEALSIZE 
from [dbo].[sales_data]  
group by DEALSIZE
order by total_sales desc


with pct as (
select SUM(sales)as total_sales,[COUNTRY] 
,(select SUM(Sales) from [dbo].[sales_data]) as total
from [dbo].[sales_data] --factor 
group by [COUNTRY]
)
select *,(total_sales/total)*100 as pct 
from pct 
order by pct desc



select productline ,round(sum(sales),2) as Total_sales
from [dbo].[sales_data]
group by PRODUCTLINE
order by Total_sales desc
--THE Classic car hit the most revenue , So let's deep dive to it


select productline ,round(sum(sales),2) as Total_sales ,YEAR_ID,MONTH_ID
from [dbo].[sales_data]
where productline ='classic cars'
group by PRODUCTLINE, YEAR_ID,MONTH_ID
order by Total_sales desc
--it seems like the fourth quarter is the most profitble part 


----what is the loyal customer with rfm 
--now we will do temp table to made solution easy
drop table if exists #rfm 
;with rfm as(
		select 
		customername 
		,round(SUM(sales),2) as Montry 
		,round(AVG(sales),2) as AVG_Montry
		,COUNT(*) as Frequincy 
		,MAX(orderdate) as last_order_date
		,(select MAX(orderdate) from [dbo].[sales_data] ) as last_order
		,DATEDIFF(DD,MAX(orderdate),(select MAX(orderdate) from [dbo].[sales_data] )) as Rencency
		from [dbo].[sales_data]
		group by customername
),
rfm_calc as(
	select r.* 
	,NTILE(4) over(order by Rencency) as rfm_Rencency
	,NTILE(4) over(order by Montry) as rfm_AVG_Montry
	,NTILE(4) over(order by Frequincy) as rfm_Frequincy
	from rfm r
)
select *
,CAST(rfm_Rencency as varchar) + CAST(rfm_AVG_Montry as varchar) + CAST(rfm_Frequincy as varchar) as rfm_str
into #rfm
from rfm_calc

--now we get this when r = 1 so it's good ,when m = 1 too bad ,f = 1 too bad 
--so the ideal concumer should be the low r and high with fm 

select 
customername
,rfm_Rencency
,rfm_AVG_Montry
,rfm_Frequincy
,	case
		when rfm_str in(111,121,112,122,123,132,211,212,114,141) then 'lost cutomer'
		when rfm_str in(143,133,134,244,334,343,344) then 'can not loss'
		when rfm_str in(311,411,331) then 'new customer'
		when rfm_str in(222,223,233,322,312) then 'potential churn'
		when rfm_str in(323,333,321,422,332,432,421,412,423,234) then 'active'
		when rfm_str in(433,434,443,444,144) then 'loyal '
end as customer_seg
from #rfm
