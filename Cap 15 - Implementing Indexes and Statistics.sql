/*
Lesson 1: Implementing Indexes

O SQL Server organiza internamente em arquivos de dados em páginas. Uma páigna é uma unidade de 8Kb e pertence a um único objeto; por exemplo, uma tabela ou índice. Uma página é a menor unidade de leitura e escrita.
Páginas são então organizadas em extensões. Uma extensão consiste de 8 páginas consecutivas. Se as páginas pertencem a vários objetos, é chamada uma extensão mista; se pertence a um único objeto, 
é chamada de uma extensão uniforme. Quando um objeto excede as 8 páginas, o SQL Server aloca uma nova extensão uniforme para ele. Com essa organização, objetos pequenos desperdiçam menos espaço e objetos 
grandes são menos fragmentados.

Páginas são estruturas físicas. O SQL Server organiza os dados das páginas em estruturas lógicas.
O SQL Server organiza as tabelas como pilhas ou árvores balanceadas. Uma tabela organizada como uma árvore balanceada também é conhecida como uma tabela clusterizada ou um índice clusterizado.
(Você pode usar esses termos alternandamente)

Índices são sempre organizados como árvores balanceadas. Outros índices, como índices que não contém todos os dados e servem como ponteiros para linhas de tabelas para buscas mais rápidas, são chamados de 
índices não-clusterizados.

Uma pilha é uma estrutura muito simples. Dados em uma pilha não são organizados em nenhuma ordem lógica. Uma pilha é apenas um monte de páginas e extensões.
O SQL server rastreia quais páginas e extensões pertencem a um objeto através de páginas especiais do sistema chamadas de Mapa de Alocação de ìndices (IAM). Toda tabela ou índice tem no mínimo uma página IAM, 
chamada primeiro IAM. Um simples IAM pode apontar para aproximadamente 4Gb de espaço. Grandes objetos podem ter mais que uma página IAM. 

Páginas IAM de um objeto são organizadas como listas duplamente ligadas; cada página tem um ponteiro para seu descendente e seu ascendente. O SQL Server armazena ponteiros paras as primeiras IAMs em suas próprias tabelas internas.

Você entenderá melhor as estruturas do SQL Server com exemplos. O código a seguir cria uma tabela como uma pilha.

*/

CREATE TABLE dbo.TestStructure
(
id INT NOT NULL,
filler1 CHAR(36) NOT NULL,
filler2 CHAR(216) NOT NULL
);

/*
Se você não criar um índice explicitamente ou implicitamente por meio de uma chave primária ou restrição UNIQUE, a tabela será organizada como uma pilha. 
O SQL Server não aloca nenhuma página para a tabela que você criou. Ele aloca a primeira página e também a primeira página IAM assim que você insere a primeira linha.

A consulta a seguir recupera informações básicas sobre a tabela TestStructure que você criou no código anterior.
*/

SELECT OBJECT_NAME(object_id) AS table_name,
name AS index_name, type, type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.TestStructure', N'U');


/*
A coluna type armazaena um valor 0 para pilhas, 1 para tabelas(índices) clusterizadas e 2 para índices não-clusterizados. 

*/

SELECT index_type_desc, page_count,
record_count, avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats
(DB_ID(N'TSQL2012'), OBJECT_ID(N'dbo.TestStructure'), NULL, NULL , 'DETAILED');
EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure', @updateusage = true;
--heap allocation check

INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(1, 'a', 'b');

DECLARE @i AS int = 1;
WHILE @i < 30
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(@i, 'a', 'b');
END;

INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(31, 'a', 'b');

DECLARE @i AS int = 31;
WHILE @i < 240
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(@i, 'a', 'b');
END;

INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(241, 'a', 'b');

/*
Você organiza a tabela como uma árvore balanceada quando cria um índice clusterizado. Os dados são organizados em uma ordem lógica da clave clusterizada.
Note que que osdados ainda são armazenados logaicamente e não fisicamente em ordem. O SQL Server ainda usa páginas IAM para seguir a alocação física.
*/

--ALTER INDEX…REORGANIZE ou ALTER INDEX…REBUILD

TRUNCATE TABLE dbo.TestStructure;
CREATE CLUSTERED INDEX idx_cl_id ON dbo.TestStructure(id);

SELECT OBJECT_NAME(object_id) AS table_name,
name AS index_name, type, type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.TestStructure', N'U');


DECLARE @i AS int = 0;
WHILE @i < 18630
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(@i, 'a', 'b');
END;

SELECT index_type_desc, index_depth, index_level, page_count,
record_count, avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats
(DB_ID(N'TSQL2012'), OBJECT_ID(N'dbo.TestStructure'), NULL, NULL , 'DETAILED');
--clustered index allocation check

INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(18631, 'a', 'b');

TRUNCATE TABLE dbo.TestStructure;
DECLARE @i AS int = 0;
WHILE @i < 8908
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(@i % 100, 'a', 'b');
END;

INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(8909 % 100, 'a', 'b');

TRUNCATE TABLE dbo.TestStructure;
GO
DROP INDEX idx_cl_id ON dbo.TestStructure;
GO
CREATE CLUSTERED INDEX idx_cl_filler1 ON dbo.TestStructure(filler1);
DECLARE @i AS int = 0;
WHILE @i < 9000
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(@i, FORMAT(@i,'0000'), 'b');
END;

SELECT index_level, page_count,
avg_page_space_used_in_percent, avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats
(DB_ID(N'TSQL2012'), OBJECT_ID(N'dbo.TestStructure'), NULL, NULL , 'DETAILED');
--fragmentation check

TRUNCATE TABLE dbo.TestStructure;
GO
DECLARE @i AS int = 0;
WHILE @i < 9000
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.TestStructure
(id, filler1, filler2)
VALUES
(@i, CAST(NEWID() AS CHAR(36)), 'b');
END;
/*
Em linhas gerais, reorganize o índice se a fragmentação for abaixo de 30% e reconstrua se for acima.
*/

ALTER INDEX idx_cl_filler1 ON dbo.TestStructure REBUILD;

--Indexed Views

SET STATISTICS IO ON;
-- Aggregate query with a join
SELECT O.shipcountry, SUM(OD.qty) AS totalordered
FROM Sales.OrderDetails AS OD
INNER JOIN Sales.Orders AS O
ON OD.orderid = O.orderid
GROUP BY O.shipcountry;

-- Create a view from the query
CREATE VIEW Sales.QuantityByCountry
WITH SCHEMABINDING -- Necessário para uma view ser indexada
AS
SELECT O.shipcountry, SUM(OD.qty) AS total_ordered,
COUNT_BIG(*) AS number_of_rows
FROM Sales.OrderDetails AS OD
INNER JOIN Sales.Orders AS O
ON OD.orderid = O.orderid
GROUP BY O.shipcountry;
GO
-- Index the view
CREATE UNIQUE CLUSTERED INDEX idx_cl_shipcountry
ON Sales.QuantityByCountry(shipcountry);
GO

SELECT * FROM Sales.QuantityByCountry

SET STATISTICS IO OFF;
DROP VIEW Sales.QuantityByCountry;


/*
Lesson 2: Using Search Arguments
*/

SELECT OBJECT_NAME(S.object_id) AS table_name,
I.name AS index_name,
S.user_seeks, S.user_scans, s.user_lookups
FROM sys.dm_db_index_usage_stats AS S
INNER JOIN sys.indexes AS i
ON S.object_id = I.object_id
AND S.index_id = I.index_id
WHERE S.object_id = OBJECT_ID(N'Sales.Orders', N'U');
--index usage query

SELECT orderid, custid, shipcity
FROM Sales.Orders;

SELECT orderid, custid, shipcity
FROM Sales.Orders
WHERE shipcity = N'Vancouver';

SELECT shipregion, COUNT(*) AS num_regions
FROM Sales.Orders
GROUP BY shipregion;

SELECT shipregion
FROM Sales.Orders
ORDER BY shipregion;

CREATE NONCLUSTERED INDEX idx_nc_shipregion ON Sales.Orders(shipregion);


DROP INDEX idx_nc_shipregion ON Sales.Orders;

--Search Arguments
SELECT orderid, custid, orderdate, shipname
FROM Sales.Orders
WHERE DATEDIFF(day, '20060709', orderdate) <= 2
AND DATEDIFF(day, '20060709', orderdate) > 0;
-- não é um SARG

SELECT orderid, custid, orderdate, shipname
FROM Sales.Orders
WHERE DATEADD(day, 2, '20060709') >= orderdate
AND '20060709' < orderdate;
--é um SARG
--O operador lógico AND é mais performático que o OR



/*
Lesson 3: Understanding Statistics
*/

DECLARE @statistics_name AS NVARCHAR(128), @ds AS NVARCHAR(1000);
DECLARE acs_cursor CURSOR FOR
SELECT name AS statistics_name
FROM sys.stats
WHERE object_id = OBJECT_ID(N'Sales.Orders', N'U')
AND auto_created = 1;
OPEN acs_cursor;
FETCH NEXT FROM acs_cursor INTO @statistics_name;
WHILE @@FETCH_STATUS = 0
BEGIN
SET @ds = N'DROP STATISTICS Sales.Orders.' + @statistics_name +';';
EXEC(@ds);
FETCH NEXT FROM acs_cursor INTO @statistics_name;
END;
CLOSE acs_cursor;
DEALLOCATE acs_cursor;

SELECT OBJECT_NAME(object_id) AS table_name,
name AS statistics_name, auto_created
FROM sys.stats
WHERE object_id = OBJECT_ID(N'Sales.Orders', N'U');

ALTER INDEX idx_nc_empid ON Sales.Orders REBUILD;

DBCC SHOW_STATISTICS(N'Sales.Orders',N'idx_nc_empid') WITH HISTOGRAM;
DBCC SHOW_STATISTICS(N'Sales.Orders',N'idx_nc_empid') WITH STAT_HEADER;

CREATE NONCLUSTERED INDEX idx_nc_custid_shipcity ON Sales.Orders(custid, shipcity);

SELECT orderid, custid, shipcity
FROM Sales.Orders
WHERE custid = 42;

SELECT OBJECT_NAME(object_id) AS table_name,
name AS statistics_name
FROM sys.stats
WHERE object_id = OBJECT_ID(N'Sales.Orders', N'U')
AND auto_created = 1;

SELECT orderid, custid, shipcity
FROM Sales.Orders
WHERE shipcity = N'Vancouver';

SELECT OBJECT_NAME(s.object_id) AS table_name,
S.name AS statistics_name, C.name AS column_name
FROM sys.stats AS S
INNER JOIN sys.stats_columns AS SC
ON S.stats_id = SC.stats_id
INNER JOIN sys.columns AS C
ON S.object_id= C.object_id AND SC.column_id = C.column_id
WHERE S.object_id = OBJECT_ID(N'Sales.Orders', N'U')
AND auto_created = 1;

DROP INDEX idx_nc_custid_shipcity ON Sales.Orders;

