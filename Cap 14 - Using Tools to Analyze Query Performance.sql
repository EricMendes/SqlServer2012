/*
Escrever consultas requer conhecimentos b�sicos de T-SQL; Escrever consultas com boa performance requer conhecimentos avan�ados. 

Lesson 1: Getting Started with Query Optimization

Toda consulta pode ser feita de v�rias formas diferentes, e a quantidade cresce exponencialmente com a complexidade da consulta.
Por exemplo, analise a pseudo-consulta abaixo:

SELECT A.col5, SUM(C.col6) AS col6sum
FROM TableA AS A 
INNER JOIN TableB AS B ON A.col1 = B.col1
INNER JOIN TableC AS C ON B.col2 = c.col2
WHERE A.col3 = constant 1
	AND B.col4 = constant2
GROUP BY A.col5; 

Come�ando com a cl�usula FROM. Quais tabelas o SQL Server deve fazer o "join" primeiro, A e B ou B e C? E em cada join, qual deve ser a da direita e qual a da esquerda?
O n�mero de possibilidades � 6, se os dois joins forem avaliados de forma linear, um ap�s o outro.
Com a avalia��o de m�ltiplos joins ao mesmo tempo, as combina��es poss�veis sobem para 12.
A f�rmula para as combina��es poss�veis � n! (n fatorial) para avalia��es lineares e (2n-2)!/(n-1)! para avalia��es paralelas.
Ainda, o SQL server pode realizar um join de formas diferentes. Ele pode usar qualquer um dos algoritmos de join abaixo:
- Nested Loops
- Merge
- Hash
- Bitmap Filtering Optimized Hash (also called Star join optimization)

Isso lhe d� quatro op��es para cada join. Ent�o, at� agora, temos 6 x 4 = 24 op��es diferentes apenas para a cl�usula FROM. Mas a situa��o real � ainda pior: O SQL Server pode executar um
Hash Join de tr�s formas diferentes.

Na cl�usula WHERE, duas express�es est�o conectadas com um operador l�gico AND, que � comutativo, ent�o o SQL Server pode avaliar a segunda express�o primeiro. 
Mais uma vez, temos mais duas possibilidades. At� agora, s�o 6 x 4 x 2 = 48 escolhas. E novamente, a situa��o real � muito pior. Como na pseudo-consulta todos os joins s�o INNER JOIN e todas
as express�es na cl�usula WHERE s�o comutativas, o SQL Server pode at� come�ar a executar a primeira express�o da cl�usula WHERE, ent�o trocar para o FROM e realizar o primeiro JOIN, voltar para a segunda 
express�o em WHERE e ent�o realizar o segundo join. Ent�o o n�mero de possibilidades � muito maior que 48.

Para uma vis�o superficial, continuemos com a cl�usula GROUP BY. O SQL Server pode executar esta parte de duas formas, como um ordered group ou como um hash group. Ent�o a quantidade de op��es � 
 6 x 4 x 2 x 2 = 96. Voc� pode parar de analisar as op��es para a pseudo-consulta. A conclus�o importante � que a quantidade de op��es cresce exponencialmente com a complexidade da consulta.


Como o SQL Server executa uma consulta:

T-SQL			- Statement to execute

Parsing			- Check the syntax
				- Parse tree of logical operators

Binding			- Name resolution � check whether objects exist
				- Algebrized tree � parse tree associated with objects

Optimization	- Generation of candidate plans and selection of a plan
				- Execution plan � logical operators mapped to physical operators

Execution		- Query execution
				- Plan caching

Lesson Summary
- The Query Optimizer generates candidate execution plans and evaluates them.
- SQL Server provides many tools that help you analyze your queries, including Extended
	Events, SQL Trace, and SQL Server Profiler.
- Extended Events is a more lightweight monitoring mechanism than SQL Trace.
- SQL Server Profiler provides you with the UI to access SQL Trace.


Lesson 2: Using SET Session Options and Analyzing Query Plans

*/

DBCC DROPCLEANBUFFERS;
--DBCC DROPCLEANBUFFERS limpa os dados em cache; Tenha cuidado ao fazer isso em produ��o, pois o SQL Server guarda os dados em cache para agilizar as consultas
SET STATISTICS IO ON;
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Orders;

/*
Resultado:

DBCC execution completed. If DBCC printed error messages, contact your system administrator.

(91 row(s) affected)
Table 'Customers'. Scan count 1, logical reads 5, physical reads 1, read-ahead reads 8, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

(830 row(s) affected)
Table 'Orders'. Scan count 1, logical reads 21, physical reads 1, read-ahead reads 25, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

SCAN COUNT
	O n�mero de procura em �ndices ou tabelas realizados.
LOGICAL READS
	O n�mero de p�ginas lidas dos dados em cache. Quando voc� l� toda uma tabela como no exemplo, este n�mero lhe d� uma estimativa sobre o tamanho da tabela.
PHYSICAL READS
	O n�mero de p�ginas lidas do disco. Este n�mero � menor que o n�mero atual de p�ginas porque muitas p�ginas est� em cache.
READ-AHEAD READS 
	O n�mero de p�ginas que o SQL Server l� � frente.
LOB LOGICAL READS 
	O n�mero de p�ginas de LOB (objetos grandes) lidas dos dados em cache. LOBs s�o colunas dos tipos VARCHAR(MAX), NVARCHAR(MAX), VARBINARY(MAX),
	TEXT, NTEXT, IMAGE, XML, ou grandes CLR data types, incluindo o tipo espacial GEOMETRY and GEOGRAPHY do sistema.
LOB PHYSICAL READS 
	O n�mero de p�ginas de LOB lidas do disco.
LOB READ-AHEAD READS
	O n�mero de p�ginas de LOB que o SQL Server l� � frente.

*/
DBCC DROPCLEANBUFFERS;
SET STATISTICS IO ON;
SELECT C.custid, C.companyname,
O.orderid, O.orderdate
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
ON C.custid = O.custid
SELECT C.custid, C.companyname,
O.orderid, O.orderdate
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
ON C.custid = O.custid
WHERE O.custid < 5


SET STATISTICS TIME ON;
DBCC DROPCLEANBUFFERS;
SELECT C.custid, C.companyname,
O.orderid, O.orderdate
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
ON C.custid = O.custid;
DBCC DROPCLEANBUFFERS;
SELECT C.custid, C.companyname,
O.orderid, O.orderdate
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
ON C.custid = O.custid
WHERE O.custid < 5;

/*
- SET SHOWPLAN_TEXT and SET SHOWPLAN_ALL for estimated plans
- SET STATISTICS PROFILE for actual plans
You can turn on and off XML plans with the following commands:
- SET SHOWPLAN_XML for estimated plans
- SET STATISTICS XML for actual plans

*/

SELECT C.custid, MIN(C.companyname) AS companyname,
COUNT(*) AS numorders
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
ON C.custid = O.custid
WHERE O.custid < 5
GROUP BY C.custid
HAVING COUNT(*) > 6;

/*
Lesson 3: Using Dynamic Management Objects

Mesmo com Extended Events, SQL Trace, SQL Server Profiler, SET session options, e os execution
plans das ferramentas do SQL Server para lhe ajudar, as op��es de otimiza��o ainda n�o est�o exauridas.
O SQL server se monitora constantemente e re�ne informa��es �teis para monitorar a sa�de de uma inst�ncia, achando problemas como �ndices perdidos, e otimizando consultas.
O SQL Server exp�e essas informa��es pelos DMOs (dynamic management objects). Esses objetos incluem dynamic management views e dynamic management functions.
Todos os DMOs est�o no schema system e come�am com "dm_.".

Apesar de extremamente �teis, os DMOs tem alguns inconvenientes. A quest�o mais importante � quando ele foi reiniciado pela �ltima vez. 
A informa��o cumulativa � in�til se a inst�ncia foi reniciada recentemente.

Os DMOs mais importantes para melhoria das consultas s�o:

- SQL Server Operating System (SQLOS)�related DMOs The SQLOS manages operating
system resources that are specific to SQL Server.

- Execution-related DMOs These DMOs provide you with insight into queries that
have been executed, including their query text, execution plan, number of executions,
and more.

- Index-related DMOs These DMOs provide useful information about index usage
and missing indexes.

*/

SELECT cpu_count AS logical_cpu_count,
cpu_count / hyperthread_ratio AS physical_cpu_count,
CAST(physical_memory_kb / 1024. AS int) AS physical_memory__mb,
sqlserver_start_time
FROM sys.dm_os_sys_info;

/*
The query returns information about the number of logical CPUs, physical CPUs, physical
memory, and the time at which SQL Server was started. The last information tells you whether
it makes sense to analyze cumulative information or not.
*/

SELECT S.login_name, S.host_name, S.program_name,
WT.session_id, WT.wait_duration_ms, WT.wait_type,
WT.blocking_session_id, WT.resource_description
FROM sys.dm_os_waiting_tasks AS WT
INNER JOIN sys.dm_exec_sessions AS S
ON WT.session_id = S.session_id
WHERE s.is_user_process = 1;

SELECT S.login_name, S.host_name, S.program_name,
R.command, T.text,
R.wait_type, R.wait_time, R.blocking_session_id
FROM sys.dm_exec_requests AS R
INNER JOIN sys.dm_exec_sessions AS S
ON R.session_id = S.session_id
OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) AS T
WHERE S.is_user_process = 1;

SELECT TOP (5)
(total_logical_reads + total_logical_writes) AS total_logical_IO,
execution_count,
(total_logical_reads/execution_count) AS avg_logical_reads,
(total_logical_writes/execution_count) AS avg_logical_writes,
(SELECT SUBSTRING(text, statement_start_offset/2 + 1,
(CASE WHEN statement_end_offset = -1
THEN LEN(CONVERT(nvarchar(MAX),text)) * 2
ELSE statement_end_offset
END - statement_start_offset)/2)
FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
FROM sys.dm_exec_query_stats
ORDER BY (total_logical_reads + total_logical_writes) DESC;

/*
sys.dm_db_missing_index_details
sys.dm_db_missing_index_columns 
sys.dm_db_missing_index_groups
sys.dm_db_missing_index_group_stats
ys.dm_db_index_usage_stats

*/


--Achar �ndices faltantes
SELECT MID.statement AS [Database.Schema.Table],
MIC.column_id AS ColumnId,
MIC.column_name AS ColumnName,
MIC.column_usage AS ColumnUsage,
MIGS.user_seeks AS UserSeeks,
MIGS.user_scans AS UserScans,
MIGS.last_user_seek AS LastUserSeek,
MIGS.avg_total_user_cost AS AvgQueryCostReduction,
MIGS.avg_user_impact AS AvgPctBenefit
FROM sys.dm_db_missing_index_details AS MID
CROSS APPLY sys.dm_db_missing_index_columns (MID.index_handle) AS MIC
INNER JOIN sys.dm_db_missing_index_groups AS MIG
ON MIG.index_handle = MID.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats AS MIGS
ON MIG.index_group_handle=MIGS.group_handle
ORDER BY MIGS.avg_user_impact DESC;

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