use northwind;

-- 1.	What are the key factors influencing customer retention or loyalty based on the dataset?
SELECT
  DATE_FORMAT(OrderDate, '%Y-%m') AS months,
  COUNT(DISTINCT CustomerID) AS customers,
  COUNT(DISTINCT CASE WHEN OrderDate BETWEEN DATE_SUB(OrderDate, INTERVAL 1 MONTH) AND 
  OrderDate THEN CustomerID END) AS retained_customers,
  ROUND(COUNT(DISTINCT CASE WHEN OrderDate BETWEEN 
  DATE_SUB(OrderDate, INTERVAL 1 MONTH) AND OrderDate THEN CustomerID END) / COUNT(DISTINCT CustomerID) * 100, 2)
  AS retention_rate
FROM
  orders
GROUP BY
  months
ORDER BY
  months;
  
-- 2.	How do customer preferences vary based on their location or demographics? Can we explore this through interactive visualizations?
SELECT c.Country, p.ProductName, COUNT(*) as TotalOrders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.Country, p.ProductName;
-- 3 Are there any interesting patterns or clusters in customer behavior that can be visualized to identify potential market segments?
SELECT c.Country, p.ProductName, COUNT(*) as TotalOrders, round(AVG(od.UnitPrice * od.Quantity),2)as AvgOrderValue
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.Country, p.ProductName;
-- ORDER BY c.Country, TotalOrders DESC;
-- 4.	Are there any specific product categories or SKUs that contribute significantly to order revenue? Can we identify them through visualizations?

SELECT cat.CategoryName, round(SUM(od.UnitPrice * od.Quantity),2) as TotalRevenue
FROM Order_Details od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories cat ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName;

-- analyze the data at the SKU level,

SELECT p.ProductName, round(SUM(od.UnitPrice * od.Quantity),2) as TotalRevenue
FROM Order_Details od
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalRevenue DESC;

-- ORDER BY TotalRevenue DESC;
-- 5.	Are there any correlations between order size and customer demographics or product categories
SELECT
  c.Country,
  AVG(o.TotalAmount) AS AverageOrderSize
FROM
  customers c
JOIN
  (SELECT
    o.OrderID,
    o.CustomerID,
    SUM(od.UnitPrice * od.Quantity) AS TotalAmount
  FROM
    orders o
  JOIN
    order_details od
  ON
    o.OrderID = od.OrderID
  GROUP BY
    o.OrderID,
    o.CustomerID) o
ON
  c.CustomerID = o.CustomerID
GROUP BY
  c.Country;
-- 6.How does order frequency vary across different customer segments? Can we visualize this using bar charts or treemaps?
-- Find the average number of orders per customer by country
SELECT
  c.Country,
  AVG(o.OrderCount) AS AverageOrderFrequency
FROM
  customers c
JOIN
  (SELECT
    CustomerID,
    COUNT(OrderID) AS OrderCount
  FROM
    orders
  GROUP BY
    CustomerID) o
ON
  c.CustomerID = o.CustomerID
GROUP BY
  c.Country;

-- 7.	Are there any correlations between employee satisfaction levels and key performance indicators? Can we explore this visually through scatter plots or line charts?
SELECT
  e.EmployeeID,e.Title,
  Round(SUM(o.Sales),2) AS TotalSales
FROM
  employees e
JOIN
  (SELECT
    o.OrderID,
    o.EmployeeID,
    SUM(od.UnitPrice * od.Quantity) AS sales
  FROM orders o
  JOIN order_details od ON
    o.OrderID = od.OrderID
  GROUP BY
    o.OrderID,
    o.EmployeeID) o
ON
  e.EmployeeID = o.EmployeeID -- corrected join condition
GROUP BY
  1,2;
  
-- 10 Are there any correlations between product attributes (e.g., size, color, features) and sales performance? 
SELECT o.OrderID, o.OrderDate, e.EmployeeID, e.FirstName, e.LastName,
       od.ProductID, p.ProductName, p.CategoryID,
       od.UnitPrice, od.Quantity
FROM Orders o
JOIN Employees e ON o.EmployeeID = e.EmployeeID
JOIN order_details od ON o.OrderID = od.OrderID
JOIN products p ON od.ProductID = p.ProductID;

-- 11.	How does product demand fluctuate over different seasons or months? Can we visualize this through line charts or area charts?

SELECT p.ProductID, p.ProductName, MONTH(o.OrderDate) AS Month, SUM(od.Quantity) AS TotalQuantity
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductID, MONTH(o.OrderDate)
ORDER BY p.ProductID, MONTH(o.OrderDate);

-- 12 Can we identify any outliers or anomalies in product performance or sales using visualizations? How can this information be used for product optimization?
SELECT p.ProductID, p.ProductName, SUM(od.Quantity) AS TotalSales
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductID
ORDER BY TotalSales DESC;

-- 13.	Are there any correlations between supplier attributes (e.g., location, size, industry) and performance metrics (e.g., on-time delivery, product quality)? Can we explore this visually through scatter plots or heatmaps?
SELECT p.ProductID, p.ProductName, s.SupplierID, s.CompanyName,
       o.OrderID, o.OrderDate
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
JOIN Orders o ON o.ShipCountry = s.Country;

-- 14  How does supplier performance vary across different product categories or departments? Can we visualize this using stacked bar charts or grouped column charts?
SELECT s.SupplierID, s.CompanyName, p.CategoryID,
       SUM(od.Quantity) AS TotalSales
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN Order_Details od ON p.ProductID = od.ProductID
GROUP BY s.SupplierID, p.CategoryID;

-- 15.Can we identify any trends or patterns in supplier costs or pricing structures through visualizations? How can this information be used for procurement optimization?
SELECT s.SupplierID, s.CompanyName, p.ProductID, p.ProductName,
       p.UnitPrice
FROM Suppliers s 
JOIN Products p ON s.SupplierID = p.SupplierID;


-- 8 How does employee turnover vary across different departments or job roles? Can we visualize this using bar charts or heatmaps?

SELECT e.EmployeeID, e.FirstName, e.LastName, e.Title, SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM Order_Details od
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Employees e ON o.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID;

