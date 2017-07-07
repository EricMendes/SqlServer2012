/*
Lesson 1 - Usando Joins

*/

SELECT D.n AS theday, S.n AS shiftno
FROM dbo.Nums AS D
CROSS JOIN dbo.Nums AS S
WHERE D.n <= 7
AND S.N <= 3
ORDER BY theday, shiftno;

SELECT
S.companyname AS supplier, S.country,
P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
INNER JOIN Production.Products AS P
ON S.supplierid = P.supplierid
WHERE S.country = N'Japan';

SELECT E.empid,
E.firstname + N' ' + E.lastname AS emp,
M.firstname + N' ' + M.lastname AS mgr
FROM HR.Employees AS E
INNER JOIN HR.Employees AS M
ON E.mgrid = M.empid;

SELECT
S.companyname AS supplier, S.country,
P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
LEFT OUTER JOIN Production.Products AS P
ON S.supplierid = P.supplierid
WHERE S.country = N'Japan';

SELECT
S.companyname AS supplier, S.country,
P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
LEFT OUTER JOIN Production.Products AS P
ON S.supplierid = P.supplierid
AND S.country = N'Japan';

SELECT
S.companyname AS supplier, S.country,
P.productid, P.productname, P.unitprice,
C.categoryname
FROM Production.Suppliers AS S
LEFT OUTER JOIN Production.Products AS P
ON S.supplierid = P.supplierid
INNER JOIN Production.Categories AS C
ON C.categoryid = P.categoryid
WHERE S.country = N'Japan';

SELECT
S.companyname AS supplier, S.country,
P.productid, P.productname, P.unitprice,
C.categoryname
FROM Production.Suppliers AS S
LEFT OUTER JOIN
(Production.Products AS P
INNER JOIN Production.Categories AS C
ON C.categoryid = P.categoryid)
ON S.supplierid = P.supplierid
WHERE S.country = N'Japan';

SELECT productid, productname, unitprice
FROM Production.Products
WHERE unitprice =
(SELECT MIN(unitprice)
FROM Production.Products);

SELECT productid, productname, unitprice
FROM Production.Products
WHERE supplierid IN
(SELECT supplierid
FROM Production.Suppliers
WHERE country = N'Japan');

SELECT categoryid, productid, productname, unitprice
FROM Production.Products AS P1
WHERE unitprice =
(SELECT MIN(unitprice)
FROM Production.Products AS P2
WHERE P2.categoryid = P1.categoryid);

SELECT custid, companyname
FROM Sales.Customers AS C
WHERE EXISTS
(SELECT *
FROM Sales.Orders AS O
WHERE O.custid = C.custid
AND O.orderdate = '20070212');

SELECT custid, companyname
FROM Sales.Customers AS C
WHERE NOT EXISTS
(SELECT *
FROM Sales.Orders AS O
WHERE O.custid = C.custid
AND O.orderdate = '20070212');

SELECT
ROW_NUMBER() OVER(PARTITION BY categoryid
ORDER BY unitprice, productid) AS rownum,
categoryid, productid, productname, unitprice
FROM Production.Products;

SELECT categoryid, productid, productname, unitprice
FROM (SELECT
ROW_NUMBER() OVER(PARTITION BY categoryid
ORDER BY unitprice, productid) AS rownum,
categoryid, productid, productname, unitprice
FROM Production.Products) AS D
WHERE rownum <= 2;

WITH C AS
(
SELECT
ROW_NUMBER() OVER(PARTITION BY categoryid
ORDER BY unitprice, productid) AS rownum,
categoryid, productid, productname, unitprice
FROM Production.Products
)
SELECT categoryid, productid, productname, unitprice
FROM C
WHERE rownum <= 2;

WITH EmpsCTE AS
(
SELECT empid, mgrid, firstname, lastname, 0 AS distance
FROM HR.Employees
WHERE empid = 9
UNION ALL
SELECT M.empid, M.mgrid, M.firstname, M.lastname, S.distance + 1 AS distance
FROM EmpsCTE AS S
JOIN HR.Employees AS M
ON S.mgrid = M.empid
)
SELECT empid, mgrid, firstname, lastname, distance
FROM EmpsCTE;

SELECT S.supplierid, S.companyname AS supplier, A.*
FROM Production.Suppliers AS S
CROSS APPLY (SELECT productid, productname, unitprice
FROM Production.Products AS P
WHERE P.supplierid = S.supplierid
ORDER BY unitprice, productid
OFFSET 0 ROWS FETCH FIRST 2 ROWS ONLY) AS A
WHERE S.country = N'Japan';

SELECT S.supplierid, S.companyname AS supplier, A.*
FROM Production.Suppliers AS S
OUTER APPLY (SELECT productid, productname, unitprice
FROM Production.Products AS P
WHERE P.supplierid = S.supplierid
ORDER BY unitprice, productid
OFFSET 0 ROWS FETCH FIRST 2 ROWS ONLY) AS A
WHERE S.country = N'Japan';

/*

Lesson 3 - Operadores SET

*/

SELECT country, region, city
FROM HR.Employees
UNION
SELECT country, region, city
FROM Sales.Customers;

SELECT country, region, city
FROM HR.Employees
UNION ALL
SELECT country, region, city
FROM Sales.Customers;

SELECT country, region, city
FROM HR.Employees
INTERSECT
SELECT country, region, city
FROM Sales.Customers;

SELECT country, region, city
FROM HR.Employees
EXCEPT
SELECT country, region, city
FROM Sales.Customers;



