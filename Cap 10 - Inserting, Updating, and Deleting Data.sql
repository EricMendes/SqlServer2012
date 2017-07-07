/*
/
/ Capítulo 10 - Inserting, Updating, and Deleting Data
/
*/

IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders;
GO
CREATE TABLE Sales.MyOrders
(
	orderid INT NOT NULL IDENTITY(1, 1)	CONSTRAINT PK_MyOrders_orderid PRIMARY KEY,
	custid INT NOT NULL,
	empid INT NOT NULL,
	orderdate DATE NOT NULL
	CONSTRAINT DFT_MyOrders_orderdate DEFAULT (CAST(SYSDATETIME() AS DATE)),
	freight MONEY NOT NULL
);
GO

INSERT INTO Sales.MyOrders(custid, empid, orderdate, shipcountry, freight)
VALUES(2, 19, '20120620', N'USA', 30.00);
GO

-- Para deixar o IDENTITY manual
SET IDENTITY_INSERT Sales.MyOrders ON;

INSERT INTO Sales.MyOrders(custid, empid, orderdate, shipcountry, freight) VALUES
(2, 11, '20120620', N'USA', 50.00),
(5, 13, '20120620', N'USA', 40.00),
(7, 17, '20120620', N'USA', 45.00);

INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate, freight)
SELECT o.SalesOrderID, o.CustomerID, o.SalesPersonID, o.OrderDate, o.Freight
FROM Sales.SalesOrderHeader o
inner join Person.Address a
on o.ShipToAddressID = a.AddressID
WHERE a. = N'Norway';

SET IDENTITY_INSERT Sales.MyOrders OFF;