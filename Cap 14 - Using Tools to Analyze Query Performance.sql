/*
Escrever consultas requer conhecimentos básicos de T-SQL; Escrever consultas com boa performance requer conhecimentos avançados. 

Lesson 1: Getting Started with Query Optimization

Toda consulta pode ser feita de várias formas diferentes, e a quantidade cresce exponencialmente com a complexidade da consulta.
Por exemplo, analise a pseudo-consulta abaixo:

SELECT A.col5, SUM(C.col6) AS col6sum
FROM TableA AS A 
INNER JOIN TableB AS B ON A.col1 = B.col1
INNER JOIN TableC AS C ON B.col2 = c.col2
WHERE A.col3 = constant 1
	AND B.col4 = constant2
GROUP BY A.col5; 

Começando com a cláusula FROM. Quais tabelas o SQL Server deve fazer o "join" primeiro, A e B ou B e C? E em cada join, qual deve ser a da direita e qual a da esquerda?
O número de possibilidades é 6, se os dois joins forem avaliados de forma linear, um após o outro.
Com a avaliação de múltiplos joins ao mesmo tempo, as combinações possíveis sobem para 12.
A fórmula para as combinações possíveis é n! (n fatorial) para avaliações lineares e (2n-2)!/(n-1)! para avaliações paralelas.
Ainda, o SQL server pode realizar um join de formas diferentes. Ele pode usar qualquer um dos algoritmos de join abaixo:
- Nested Loops
- Merge
- Hash
- Bitmap Filtering Optimized Hash (also called Star join optimization)

Isso lhe dá quatro opções para cada join. Então, até agora, temos 6 x 4 = 24 opções diferentes apenas para a cláusula FROM. Mas a situação real é ainda pior: O SQL Server pode executar um
Hash Join de três formas diferentes.

Na cláusula WHERE, duas expressões estão conectadas com um operador lógico AND, que é comutativo, então o SQL Server pode avaliar a segunda expressão primeiro. 
Mais uma vez, temos mais duas possibilidades. Até agora, são 6 x 4 x 2 = 48 escolhas. E novamente, a situação real é muito pior. Como na pseudo-consulta todos os joins são INNER JOIN e todas
as expressões na cláusula WHERE são comutativas, o SQL Server pode até começar a executar a primeira expressão da cláusula WHERE, então trocar para o FROM e realizar o primeiro JOIN, voltar para a segunda 
expressão em WHERE e então realizar o segundo join. Então o número de possibilidades é muito maior que 48.

Para uma visão superficial, continuemos com a cláusula GROUP BY. O SQL Server pode executar esta parte de duas formas, como um ordered group ou como um hash group. Então a quantidade de opções é 
 6 x 4 x 2 x 2 = 96. Você pode parar de analisar as opções para a pseudo-consulta. A conclusão importante é que a quantidade de opções cresce exponencialmente com a complexidade da consulta.


Como o SQL Server executa uma consulta:

T-SQL			- Statement to execute

Parsing			- Check the syntax
				- Parse tree of logical operators

Binding			- Name resolution — check whether objects exist
				- Algebrized tree — parse tree associated with objects

Optimization	- Generation of candidate plans and selection of a plan
				- Execution plan — logical operators mapped to physical operators

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
--DBCC DROPCLEANBUFFERS limpa os dados em cache; Tenha cuidado ao fazer isso em produção, pois o SQL Server guarda os dados em cache para agilizar as consultas
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
	O número de procura em índices ou tabelas realizados.
LOGICAL READS
	O número de páginas lidas dos dados em cache. Quando você lê toda uma tabela como no exemplo, este número lhe dá uma estimativa sobre o tamanho da tabela.
PHYSICAL READS
	O número de páginas lidas do disco. Este número é menor que o número atual de páginas porque muitas páginas está em cache.
READ-AHEAD READS 
	O número de páginas que o SQL Server lê à frente.
LOB LOGICAL READS 
	O número de páginas de LOB (objetos grandes) lidas dos dados em cache. LOBs são colunas dos tipos VARCHAR(MAX), NVARCHAR(MAX), VARBINARY(MAX),
	TEXT, NTEXT, IMAGE, XML, ou grandes CLR data types, incluindo o tipo espacial GEOMETRY and GEOGRAPHY do sistema.
LOB PHYSICAL READS 
	O número de páginas de LOB lidas do disco.
LOB READ-AHEAD READS
	O número de páginas de LOB que o SQL Server lê à frente.

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
plans das ferramentas do SQL Server para lhe ajudar, as opções de otimização ainda não estão exauridas.
O SQL server se monitora constantemente e reúne informações úteis para monitorar a saúde de uma instância, achando problemas como índices perdidos, e otimizando consultas.
O SQL Server expõe essas informações pelos DMOs (dynamic management objects). Esses objetos incluem dynamic management views e dynamic management functions.
Todos os DMOs estão no schema system e começam com "dm_.".

Apesar de extremamente úteis, os DMOs tem alguns inconvenientes. A questão mais importante é quando ele foi reiniciado pela última vez. 
A informação cumulativa é inútil se a instância foi reniciada recentemente.

Os DMOs mais importantes para melhoria das consultas são:

- SQL Server Operating System (SQLOS)–related DMOs The SQLOS manages operating
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


--Achar índices faltantes
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