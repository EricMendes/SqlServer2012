/*
Lesson 1 - Writing Grouped Queries

*/

SELECT COUNT(*) AS numorders
FROM Sales.Orders;

SELECT shipperid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY shipperid;

SELECT shipperid, YEAR(shippeddate) AS shippedyear,
COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY shipperid, YEAR(shippeddate);

SELECT shipperid, YEAR(shippeddate) AS shippedyear,
COUNT(*) AS numorders
FROM Sales.Orders
WHERE shippeddate IS NOT NULL
GROUP BY shipperid, YEAR(shippeddate)
HAVING COUNT(*) < 100;

SELECT shipperid,
COUNT(*) AS numorders,
COUNT(shippeddate) AS shippedorders,
MIN(shippeddate) AS firstshipdate,
MAX(shippeddate) AS lastshipdate,
SUM(val) AS totalvalue
FROM Sales.OrderValues
GROUP BY shipperid;

SELECT shipperid, COUNT(DISTINCT shippeddate) AS numshippingdates
FROM Sales.Orders
GROUP BY shipperid;

SELECT S.shipperid, S.companyname, COUNT(*) AS numorders
FROM Sales.Shippers AS S
JOIN Sales.Orders AS O
ON S.shipperid = O.shipperid
GROUP BY S.shipperid;

SELECT S.shipperid, S.companyname, COUNT(*) AS numorders
FROM Sales.Shippers AS S
JOIN Sales.Orders AS O
ON S.shipperid = O.shipperid
GROUP BY S.shipperid;

SELECT S.shipperid, S.companyname,
COUNT(*) AS numorders
FROM Sales.Shippers AS S
INNER JOIN Sales.Orders AS O
ON S.shipperid = O.shipperid
GROUP BY S.shipperid, S.companyname;

SELECT S.shipperid,
MAX(S.companyname) AS numorders,
COUNT(*) AS shippedorders
FROM Sales.Shippers AS S
INNER JOIN Sales.Orders AS O
ON S.shipperid = O.shipperid
GROUP BY S.shipperid;

SELECT shipperid, YEAR(shippeddate) AS shipyear, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY GROUPING SETS
(
( shipperid, YEAR(shippeddate)),
( shipperid ),
( YEAR(shippeddate) ),
( )
);

SELECT shipperid, YEAR(shippeddate) AS shipyear, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY CUBE( shipperid, YEAR(shippeddate));

SELECT shipperid, YEAR(shippeddate) AS shipyear, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY ROLLUP( shipperid, YEAR(shippeddate) );

SELECT
shipcountry, GROUPING(shipcountry) AS grpcountry,
shipregion , GROUPING(shipregion) AS grpcountry,
shipcity , GROUPING(shipcity) AS grpcountry,
COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY ROLLUP( shipcountry, shipregion, shipcity );

SELECT GROUPING_ID( shipcountry, shipregion, shipcity ) AS grp_id,
shipcountry, shipregion, shipcity,
COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY ROLLUP( shipcountry, shipregion, shipcity );

SELECT C.custid, C.city, COUNT(*) AS numorders
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
ON C.custid = O.custid
WHERE C.country = N'Spain'
GROUP BY GROUPING SETS ( (C.custid, C.city), () )
ORDER BY GROUPING(C.custid);


SELECT
CASE WHEN GROUPING(shipcountry) = 1 THEN 'Total' ELSE shipcountry END,
CASE WHEN GROUPING(shipregion)  = 1 THEN 'Total' ELSE shipregion END,
CASE WHEN GROUPING(shipcity)  = 1 THEN 'Total' ELSE shipcity END,
COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY ROLLUP( shipcountry, shipregion, shipcity );

WITH PivotData AS
(
SELECT
custid , -- grouping column
shipperid, -- spreading column
freight -- aggregation column
FROM Sales.Orders
)
SELECT custid, [1], [2], [3]
FROM PivotData
PIVOT(SUM(freight) FOR shipperid IN ([1],[2],[3]) ) AS P;

USE TSQL2012;
IF OBJECT_ID('Sales.FreightTotals') IS NOT NULL DROP TABLE Sales.FreightTotals;
GO
WITH PivotData AS
(
SELECT
custid , -- grouping column
shipperid, -- spreading column
freight -- aggregation column
FROM Sales.Orders
)
SELECT *
INTO Sales.FreightTotals
FROM PivotData
PIVOT( SUM(freight) FOR shipperid IN ([1],[2],[3]) ) AS P;
SELECT * FROM Sales.FreightTotals;

SELECT custid, shipperid, freight
FROM Sales.FreightTotals
UNPIVOT( freight FOR shipperid IN([1],[2],[3]) ) AS U;

/*
PIVOT -  Rotaciona os dados de um estado de linhas para um estado de colunas
UNPIVOT - Rotaciona os dados de um estado de colunas para um estado de linhas.
*/

/*

Lesson 3: Using Window Functions

Window functions são como group functions, mas com a diferença que nas GROUP FUNCTIONS você agrupa as colunas de uma query e aplica as funções no agrupamento, recebendo uma linha por agrupamento.
Nas window functions, você define o conjunto de linhas por função, e então aplica a função a cada linha. A vantagem é que você pode aplicar funções sem perder os detalhes.

Como as window functions operam no result set, elas são permitidas apenas nas cláusulas SELECT e ORDER BY. Se você precisar se referir a uma coluna gerada por uma window function, deverá usar uma CTE.
*/

SELECT custid, orderid,
val,
SUM(val) OVER(PARTITION BY custid) AS custtotal,
SUM(val) OVER() AS grandtotal
FROM Sales.OrderValues;

SELECT custid, orderid,
val,
CAST(100.0 * val / SUM(val) OVER(PARTITION BY custid) AS NUMERIC(5, 2)) AS pctcust,
CAST(100.0 * val / SUM(val) OVER() AS NUMERIC(5, 2)) AS pcttotal
FROM Sales.OrderValues;

SELECT custid, orderid, orderdate, val,
SUM(val) OVER(PARTITION BY custid
				ORDER BY orderdate, orderid
				ROWS BETWEEN UNBOUNDED PRECEDING
				AND CURRENT ROW) AS runningtotal
FROM Sales.OrderValues;

SELECT custid, orderid, val,
ROW_NUMBER() OVER(ORDER BY val) AS rownum,
RANK() OVER(ORDER BY val) AS rnk,
DENSE_RANK() OVER(ORDER BY val) AS densernk,
NTILE(100) OVER(ORDER BY val) AS ntile100
FROM Sales.OrderValues;

/*
A cláusula ORDER BY dentro da window function não garante a ordem de apresentação, e por isso, não é determinística. 
Caso precise de um resultado determinístico, use a clásula ORDER BY também fora da window function.
*/

SELECT custid, orderid, orderdate, val,
LAG(val) OVER(PARTITION BY custid
				ORDER BY orderdate, orderid) AS prev_val,
LEAD(val) OVER(PARTITION BY custid
				ORDER BY orderdate, orderid) AS next_val
FROM Sales.OrderValues;

SELECT custid, orderid, orderdate, val,
FIRST_VALUE(val) OVER(PARTITION BY custid
					ORDER BY orderdate, orderid
					ROWS BETWEEN UNBOUNDED PRECEDING
					AND CURRENT ROW) AS first_val,
LAST_VALUE(val) OVER(PARTITION BY custid
					ORDER BY orderdate, orderid
					ROWS BETWEEN CURRENT ROW
					AND UNBOUNDED FOLLOWING) AS last_val
FROM Sales.OrderValues;