-- question 1 --
with table1 as(
	select OrderID, sum(UnitPrice * Quantity*(1-Discount)) as sales 
	from order_details 
    group by 1
),
table2 as (
	select CustomerID, count(OrderID)as Number_of_orders 
    from orders 
    group by 1
)
select table2.CustomerID, sum(table2.Number_of_orders)as orders , Round(sum(table1.sales ),2)as sales
from table1 join orders on table1.OrderID= orders.OrderID
join table2 on table2.CustomerID=orders.CustomerID
group by 1 
order by 2 desc , 3 desc ;


/* question 2*/
select a.ShipCountry as Country , CategoryName, count(*)as product_count
from orders a join order_details b on a.OrderID=b.OrderID
join products c on c.ProductID=b.ProductID
join categories d on d.CategoryID=c.CategoryID
group by 1,2 
order by 1, 3 desc;

-- question 3 -- 
with table1 as(
	select a.ShipCountry as Country , CategoryName, count(*)as product_count, 
    rank() over(partition by ShipCountry order by count(*) desc)as rank_
	from orders a join order_details b on a.OrderID=b.OrderID
	join products c on c.ProductID=b.ProductID
	join categories d on d.CategoryID=c.CategoryID
	group by 1,2 
)
select Country , CategoryName as Most_popular_category, product_count 
from table1 
where rank_ = 1;

-- question 4 -- 
select CategoryName, 
round(sum(c.UnitPrice*c.Quantity*(1-c.Discount)),2)as Sales 
from categories a join products b on a.CategoryID=b.CategoryID
join order_details c on b.ProductID=c.ProductID
group by 1
order by 2 desc;

-- question 5 -- 
select CategoryName, round(avg(c.UnitPrice*c.Quantity*(1-c.Discount)),2)as Sales 
from categories a join products b on a.CategoryID=b.CategoryID
join order_details c on b.ProductID=c.ProductID
group by 1;

-- question 6 -- 
with frequency_table as(
	select a.CustomerID , count(*)as count_ ,
	case 
		when count(*) <= 3 then "low"
		when count(*) between 4 and 7 then "medium"
		else "high"
	end as order_frequency
	from customers a left join orders b on a.CustomerID=b.CustomerID
	group by 1
)
select order_frequency , count(*) as numbers
from frequency_table
group by 1 ;



-- question 7 --
with sales_table as(
	select a.EmployeeID, round(sum(b.UnitPrice*b.Quantity*(1-b.Discount)),2)as sales 
	from orders a join order_details b on a.OrderID=b.OrderID
	group by 1 
)
select * , 
case 
	when sales < 50000 then 1
    when sales between 50000 and 100000 then 2
    when sales between 100001 and 150000 then 3 
    when sales between 150001 and 200000 then 4  
    else 5
end as satisfaction_score
from sales_table;

-- question 8 -- 
select Title , round(sum(c.UnitPrice*c.Quantity*(1-c.Discount)),2)as sales 
from employees a join orders b on a.ï»¿EmployeeID=b.EmployeeID
join order_details c on b.OrderID=c.OrderID
group by 1 ;

-- question 9 --
with table1 as (
	select * ,
    case 
		when Notes like '%MBA%' then 'MBA'
        when Notes like '%BSC%' then 'BSC'
        when Notes like '%BA%' then 'BA'
        when Notes like '%BS%' then 'BS'
        when Notes like '%Ph.D.%' then 'Ph.D.'
	else 'other'
    end as Qualification 
	from employees
)
select Qualification, count(*)as employees
from table1 
group by 1 ;

-- question 10 -- 
with table1 as (
	select ProductID, 
    case 
		when lower(QuantityPerUnit) like '%box%' then 'box'
        when lower(QuantityPerUnit) like '%bottle%' then 'bottle'
        when lower(QuantityPerUnit) like '%can%' then 'can'
        when lower(QuantityPerUnit) like '%jar%' then 'jar'
        when lower(QuantityPerUnit) like '%tin%' then 'tin'
        when lower(QuantityPerUnit) like '%pkg%' then 'pkg'
	else 'other'
    end as 'packaging'
    from products
)
select packaging, round(sum(b.UnitPrice*b.Quantity*(1-b.Discount)),2)as sales 
from table1 a join order_details b on a.ProductID=b.ProductID
group by 1;

-- question 11 -- 
select date_format(OrderDate,'%Y-%m')as order_month,
count(*)as number_of_orders
from orders 
group by 1
order by 1 ;  


-- question 12 --
with table1 as (
	select a.ProductID, a.ProductName, round(sum(b.UnitPrice*b.Quantity*(1-b.Discount)),2)as sales 
    from products a join order_details b on a.ProductID=b.ProductID
    group by 1,2 
),
table2 as (
	select avg(sales) as average_sales, stddev(sales)as standard_deviation 
    from table1
)
select a.ProductID, a.ProductName, a.sales,
case
	when a.sales > average_sales + 2 * standard_deviation then 'High Outlier'
    when a.sales < average_sales - 2 * standard_deviation then 'Low Outlier'
    else 'Normal'
end as 'Outlier'
from table1 a , table2 b;

-- question 13 --
with table1 as(
	select SupplierID,
    case
		when ReorderLevel <=0 then 0
        when ReorderLevel between 1 and 6 then 1
        when ReorderLevel between 7 and 12 then 2
		when ReorderLevel between 13 and 18 then 3
        when ReorderLevel between 19 and 24 then 4
        else 5 
	end as Reorder_rating 
    from products 
)
select Country , avg(Reorder_rating)
from suppliers a left join table1 b on a.SupplierID=b.SupplierID
group by 1 
order by 2 desc;

-- question 14 --
with table1 as(
	select SupplierID, CategoryID,
    case
		when ReorderLevel <=0 then 0
        when ReorderLevel between 1 and 6 then 1
        when ReorderLevel between 7 and 12 then 2
		when ReorderLevel between 13 and 18 then 3
        when ReorderLevel between 19 and 24 then 4
        else 5 
	end as Reorder_rating 
    from products 
)
select CategoryName, CompanyName as Supplier, round(avg(Reorder_rating),2)as Rating 
from table1 a join suppliers b on a.SupplierID=b.SupplierID
join categories c on a.CategoryID=c.CategoryID
group by 1,2
order by 1 ;

-- question 15 -- 
select CompanyName as supplier, round(avg(UnitPrice),2)as average_UnitPrice
from suppliers a left join products b on a.SupplierID=b.SupplierID
group by 1 

    
 
    