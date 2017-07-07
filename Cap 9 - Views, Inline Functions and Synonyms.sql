/*
/
/ Cap�tulo 9 - Views, Inline Functions and Synonyms
/
*/

--Criando e selecionando dados de uma View
IF OBJECT_ID (N'Sales.OrderTotalsByYear', N'V') IS NOT NULL
DROP FUNCTION Sales.fn_OrderTotalsByYear;
GO

CREATE VIEW Sales.OrderTotalsByYear
WITH SCHEMABINDING
AS
SELECT
	YEAR(O.orderdate) AS orderyear,
	SUM(OD.OrderQty) AS qty
FROM Sales.SalesOrderHeader AS O
JOIN Sales.SalesOrderDetail AS OD
ON OD.SalesOrderID = O.SalesOrderID
GROUP BY YEAR(orderdate);
GO

SELECT orderyear, qty
FROM Sales.OrderTotalsByYear;

--Op��es da View:
-- WITH ENCRYPTION: Deixa dif�cil para os usu�rios descobrirem o SELECT.
-- WITH SCHEMABINDING: N�o deixa mudar a estrutura das tabelas sem dar DROP na View.
-- WITH VIEW_METADATA: Quando especificado, retorna os metadados da View ao inv�s da tabela base.
-- WITH CHECK: Quando existe uma cl�usula WHERE na View, restringe os update apenas �s linhas que atendem aos par�metros.


--Para ver os metadados das views
SELECT name, object_id, principal_id, schema_id, type
FROM sys.views;

--Criando e selecionado dados de uma Inline Function
IF OBJECT_ID (N'Sales.fn_OrderTotalsByYear', N'IF') IS NOT NULL
DROP FUNCTION Sales.fn_OrderTotalsByYear;
GO
CREATE FUNCTION Sales.fn_OrderTotalsByYear (@orderyear int)
RETURNS TABLE
AS
RETURN
(
SELECT
	YEAR(O.orderdate) AS orderyear,
	SUM(OD.OrderQty) AS qty
FROM Sales.SalesOrderHeader AS O
JOIN Sales.SalesOrderDetail AS OD
ON OD.SalesOrderID = O.SalesOrderID
WHERE YEAR(O.orderdate) = @orderyear
GROUP BY YEAR(orderdate)
);
GO

select orderyear,qty from Sales.fn_OrderTotalsByYear(2007)

--Op��es da Inline Function:
-- WITH ENCRYPTION: Deixa dif�cil para os usu�rios descobrirem o SELECT.
-- WITH SCHEMABINDING: N�o deixa mudar a estrutura das tabelas sem dar DROP na View.

--Criando e alterando um Synonym

CREATE SYNONYM dbo.ProductCategory FOR Production.ProductCategory;
GO

SELECT c.ProductCategoryID, c.Name
FROM ProductCategory c;


DROP SYNONYM dbo.ProductCategory


--Um Synonym n�o pode se referir a outro.
--Synonyms podem se referirem a um objeto em outro database com Linked Server.

