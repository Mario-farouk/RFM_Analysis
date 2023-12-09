# RFM_Analysis
<br>RFM analysis is a marketing technique used to analyze and categorize customers based on their purchasing behavior. The acronym RFM stands for Recency, Frequency, and Monetary Value, which are three key <br>dimensions used to evaluate customer engagement and contribution to a business. Here's a brief explanation of each component:

# Recency (R): 
<br>This refers to how recently a customer has made a purchase. The idea is that customers who have made a purchase more recently are more likely to respond to future marketing efforts.

# Frequency (F): 
<br>This measures how often a customer makes a purchase. Customers who buy from a business more frequently are often considered more valuable.

# Monetary Value (M): 
<br>This represents the amount of money a customer has spent on purchases. Customers who have spent more money are generally considered more valuable to a business.

<br>RFM analysis involves assigning scores or rankings to customers based on each of these dimensions. For example, you might score recency on a scale of 1 to 5, with 5 being the most recent. The same would <br>be done for frequency and monetary value. Customers are then grouped into segments based on their combined scores, creating segments like "high-value," "medium-value," and "low-value" customers.

<br>This segmentation allows businesses to tailor their marketing strategies more effectively. For instance, high-value customers might receive special offers or exclusive deals to encourage them to remain <br>loyal, while low-value customers might receive targeted promotions to increase their engagement.
# now apply code 
# first 
<br>select 
		<br>customername -- this query will return 
		<br>,round(SUM(sales),2) as Montry  --all rev to calculate montary "m"
		<br>,round(AVG(sales),2) as AVG_Montry
		<br>,COUNT(*) as Frequincy  -- Frequincy
		<br>,MAX(orderdate) as last_order_date --First we will return the last transaction each customer do  
		<br>,(select MAX(orderdate) from [dbo].[sales_data] ) as last_order -- then what is the last date in transactions 
		<br>,DATEDIFF(DD,MAX(orderdate),(select MAX(orderdate) from [dbo].[sales_data] )) as Rencency -- then we will deduct them to calculate how long days customer  
		<br>from [dbo].[sales_data]
		<br>group by customername
  # secound
  <br> -- here with cte we use ntile function to create groups for each r f m 
 <br> with rfm as(
		<br>select 
		<br>customername 
		<br>,round(SUM(sales),2) as Montry 
		<br>,round(AVG(sales),2) as AVG_Montry
		<br>,COUNT(*) as Frequincy 
		<br>,MAX(orderdate) as last_order_date
		<br>,(select MAX(orderdate) from [dbo].[sales_data] ) as last_order
		<br>,DATEDIFF(DD,MAX(orderdate),(select MAX(orderdate) from [dbo].[sales_data] )) as Rencency
		<br>from [dbo].[sales_data]
		<br>group by customername
<br>),
<br>rfm_calc as(
	<br>select r.* 
	<br>,NTILE(4) over(order by Rencency) as rfm_Rencency
	<br>,NTILE(4) over(order by Montry) as rfm_AVG_Montry
	<br>,NTILE(4) over(order by Frequincy) as rfm_Frequincy
	<br>from rfm r
 # third
 -- then we cast them for classifcation 
 <br>drop table if exists #rfm 
 <br> ;with rfm as(
		<br>select 
		<br>customername 
		<br>,round(SUM(sales),2) as Montry 
		<br>,round(AVG(sales),2) as AVG_Montry
		<br>,COUNT(*) as Frequincy 
		<br>,MAX(orderdate) as last_order_date
		<br>,(select MAX(orderdate) from [dbo].[sales_data] ) as last_order
		<br>,DATEDIFF(DD,MAX(orderdate),(select MAX(orderdate) from [dbo].[sales_data] )) as Rencency
		<br>from [dbo].[sales_data]
		<br>group by customername
<br>),
<br>rfm_calc as(
	<br>select r.* 
	<br>,NTILE(4) over(order by Rencency) as rfm_Rencency
	<br>,NTILE(4) over(order by Montry) as rfm_AVG_Montry
	<br>,NTILE(4) over(order by Frequincy) as rfm_Frequincy
	<br>from rfm r
 <br>select *
<br>,CAST(rfm_Rencency as varchar) + CAST(rfm_AVG_Montry as varchar) + CAST(rfm_Frequincy as varchar) as rfm_str
<br>into #rfm
<br>from rfm_calc
# forth 
<br>select 
<br>customername
<br>,rfm_Rencency
<br>,rfm_AVG_Montry
<br>,rfm_Frequincy
<br>,	case
		<br>when rfm_str in(111,121,112,122,123,132,211,212,114,141) then 'lost cutomer'
		<br>when rfm_str in(143,133,134,244,334,343,344) then 'can not loss'
		<br>when rfm_str in(311,411,331) then 'new customer'
		<br>when rfm_str in(222,223,233,322,312) then 'potential churn'
		<br>when rfm_str in(323,333,321,422,332,432,421,412,423,234) then 'active'
		<br>when rfm_str in(433,434,443,444,144) then 'loyal '
<br>end as customer_seg
<br>from #rfm
