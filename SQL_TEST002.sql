use northwind;

-- 1. Order Subtotals
SELECT OrderId, sum(unitPrice*Quantity) as sub_total 
FROM order_details
group by OrderId;

-- 2. Sales by Year
select distinct date(o.ShippedDate) as ShippedDate, o.OrderID, temp_table.Subtotal, year(o.ShippedDate) as Year
from Orders o 
inner join
(
    select distinct OrderID, 
        format(sum(UnitPrice * Quantity), 2) as Subtotal
    from order_details
    group by OrderID    
) 
temp_table 
on o.OrderID = temp_table.OrderID
where o.ShippedDate is not null
order by o.ShippedDate;

-- 3. Employee Sales by Country
select e.country, e.LastName,e.FirstName,date(o.ShippedDate), o.OrderId, od.Sale_Amount
from employees e
inner join orders o
using(employeeId)
inner join
(
    select distinct OrderID, 
        sum(UnitPrice * Quantity) as Sale_Amount
    from order_details
    group by OrderID    
)od  
using(OrderId)
order by e.country;

-- 4. Alphabetical List of Products
select
	productId,
    productName,
    supplierId,
    categoryId,
    quantityperunit,
    products.unitprice
from products
join order_details
using(productId)
group by productId
order by productName;

-- 5. Current Product List
select ProductID, ProductName
from products
order by ProductName;

-- 6. Order Details Extended
select distinct od.OrderID, 
    p.ProductID, 
    p.ProductName, 
    od.UnitPrice, 
    od.Quantity, 
    od.Discount, 
    round(od.UnitPrice * od.Quantity * (1 - od.Discount), 2) as ExtendedPrice
from Products p
inner join Order_Details od 
using(ProductID)
order by od.OrderID;

-- 7. Sales by Category
select distinct c.CategoryID, 
    c.CategoryName,  
    p.ProductName, 
    sum(round(od.UnitPrice * od.Quantity * (1 - od.Discount), 2)) as ProductSales
from Order_Details od
inner join Orders o 
using(OrderID)
inner join Products p 
using(ProductID)
inner join Categories c 
using(CategoryID)
where o.OrderDate between date('1997/1/1') and date('1997/12/31')
group by c.CategoryID, c.CategoryName, p.ProductName
order by c.CategoryName, p.ProductName, ProductSales;
 
-- 8. Ten Most Expensive Products
select * from
(
    select distinct ProductName as Ten_Most_Expensive_Products, 
           UnitPrice
    from Products
    order by UnitPrice desc
) as p
limit 10;

-- 9. Products by Category
select distinct c.CategoryName, 
    p.ProductName, 
    p.QuantityPerUnit, 
    p.UnitsInStock, 
    p.Discontinued
from Categories c
inner join Products p 
using(CategoryID)
where p.Discontinued = 'n'
order by c.CategoryName, p.ProductName;

-- 10. Customers and Suppliers by City
select City, CompanyName, ContactName, 'Customers' as Relationship 
from Customers
union
select City, CompanyName, ContactName, 'Suppliers'
from Suppliers
order by City, CompanyName;

-- 11. Products Above Average Price
select ProductName, UnitPrice
from Products
where UnitPrice > (select avg(UnitPrice) from Products)
order by UnitPrice;

-- 12. Product Sales for 1997
select c.CategoryName, 
    p.ProductName, 
    format(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as ProductSales,
    concat('Qtr ', quarter(o.ShippedDate)) as ShippedQuarter
from Categories c
inner join Products p 
on c.CategoryID = p.CategoryID
inner join Order_Details od 
using(ProductID)
inner join Orders o
using(OrderID)
where o.ShippedDate between date('1997-01-01') and date('1997-12-31')
group by c.CategoryName, p.ProductName, 
    concat('Qtr ', quarter(o.ShippedDate))
order by c.CategoryName, p.ProductName, ShippedQuarter;

-- 13. Category Sales for 1997
select CategoryName, format(sum(ProductSales), 2) as CategorySales
from
(
    select distinct c.CategoryName, 
        p.ProductName, 
        format(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) as ProductSales,
        concat('Qtr ', quarter(o.ShippedDate)) as ShippedQuarter
    from Categories as c
    inner join Products as p 
    using(CategoryID)
    inner join Order_Details as od
    using(ProductID)
    inner join Orders as o 
    using(OrderID) 
    where o.ShippedDate between date('1997-01-01') and date('1997-12-31')
    group by c.CategoryName, 
        p.ProductName, 
        concat('Qtr ', quarter(o.ShippedDate))
    order by c.CategoryName, 
        p.ProductName, 
        ShippedQuarter
) as temp
group by CategoryName
order by CategoryName;
    
    
-- 14. Quarterly Orders by Product
select p.ProductName, c.CompanyName, year(OrderDate) as OrderYear,
    format(sum(case quarter(o.OrderDate) 
    when '1' 
        then od.UnitPrice*od.Quantity*(1-od.Discount) else 0 end), 0) 'Qtr 1',
		format(sum(case quarter(o.OrderDate) 
    when '2' 
        then od.UnitPrice*od.Quantity*(1-od.Discount) else 0 end), 0) 'Qtr 2',
		format(sum(case quarter(o.OrderDate) 
    when '3' 
        then od.UnitPrice*od.Quantity*(1-od.Discount) else 0 end), 0) 'Qtr 3',
		format(sum(case quarter(o.OrderDate) 
    when '4' 
        then od.UnitPrice*od.Quantity*(1-od.Discount) else 0 end), 0) 'Qtr 4' 
from Products p 
inner join Order_Details od
using(ProductID)
inner join Orders o 
using(OrderID)
inner join Customers c 
using(CustomerID)
where o.OrderDate between date('1997-01-01') and date('1997-12-31')
group by p.ProductName, c.CompanyName, year(OrderDate)
order by p.ProductName, c.CompanyName;


 -- 15. Invoice
 select ShipName, 
    ShipAddress, 
    ShipCity, 
    ShipRegion, 
    ShipPostalCode
 from orders 
 order by ShipName;


-- 16. Number of units in stock by category and supplier continent
select c.CategoryName as 'Product Category', 
		case when s.Country in 
				(
					'UK','Spain','Sweden','Germany','Norway',
					'Denmark','Netherlands','Finland','Italy','France'
				)then 'Europe'
            when s.Country in ('USA','Canada','Brazil') then 'America'
            else 'Asia-Pacific'
        end as 'Supplier Continent', 
        sum(p.UnitsInStock) as UnitsInStock
from Suppliers s 
inner join Products p 
using(SupplierID)
inner join Categories c 
using(CategoryID) 
group by c.CategoryName, 
		case when s.Country in 
				(
					'UK','Spain','Sweden','Germany','Norway',
					'Denmark','Netherlands','Finland','Italy','France'
				)then 'Europe'
                
              when s.Country in ('USA','Canada','Brazil') then 'America'
              else 'Asia-Pacific'
		end;
