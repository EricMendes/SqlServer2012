/*
T-SQL é a implementação da Microsft para o dialeto SQL.
T-SQL também implementa extensões do SQL padrão.
Prefira implementações padrão do SQL do que as implementações não-padrão.
Ex.: "<>" e "!=" servem como operadores "diferente de" mas o primeiro é padrão e o segundo não.
	 CAST também e padrão e CONVERT não. Mas o CONVERT tem um argumento para o estilo que o CAST não suporta.
Segundo o padrão SQL, você deve terminar suas instruções com ponto-e-vírgula. 
No T-SQL isso não é requerido, apenas em casos onde há ambiguidade nos elementos do código.


#Consultas básicas

Elimine linhas duplicadas se possível no resultado de sua consulta.
*/

USE TSQL2012;

--Essa consulta provavelmente retornará linhas duplicadas
SELECT country
FROM HR.Employees;

--Usando o distinct você elimina as linhas duplicadas
SELECT DISTINCT country
FROM HR.Employees;

/*
Ordem das linhas

Não confie na ordem das linhas, se precisa de uma ordem específica, use o ORDER BY.
O SQL Server usa uma série de mecanismos internos para melhorar a performance da consulta, o que pode resultar em ordens 
diferentes das linhas caso não seja especificada a cláusula ORDER BY. 

Na cláusula ORDER BY você pode indicar o nome da coluna ou a posição dela na cláusula SELECT, mas o último não é considerado 
uma boa prática.

*/

--Com a instrução abaixo não se pode prever a ordem das linhas que o SQL retornará
SELECT empid, lastname
FROM HR.Employees;

--Usando o ORDER BY você garante a ordem
SELECT empid, lastname
FROM HR.Employees
ORDER BY empid;

SELECT empid, lastname
FROM HR.Employees
ORDER BY 1; --não é uma boa prática. 


/*
Aliases

Para facilitar o entendimento, você pode usar aliases em colunas.
É uma boa prática nomear os resultados de uma consulta.
*/

--A consulta abaixo concatena o nome e sobrenome para retornar o nome completo
SELECT empid, firstname + ' ' + lastname
FROM HR.Employees;

--Atribuindo um alias ao retorno você deixa mais legível e facilita o entendimento
SELECT empid, firstname + ' ' + lastname AS fullname
FROM HR.Employees;


/*
O uso da terminologia correta reflete seu conhecimento, portanto, você deve ser esforçar para entender e usá-la.
	Ex. 	Campos e registros são físicos, linhas e colunas são lógicos.
	Ex 2. 	NULL não é um valor, e sim uma marca para um valor ausente.

A ordem que o SQL Server interpreta a consulta não é a mesma ordem que você escreve a consulta.

Ordem das cláusulas para uma instrução T-SQL:

1. SELECT
2. FROM
3. WHERE
4. GROUP BY
5. HAVING
6. ORDER BY

Ordem que o SQL Server interpreta as cláusulas:

1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY
*/

SELECT country, YEAR(hiredate) AS yearhired, COUNT(*) AS numemployees
FROM HR.Employees
WHERE hiredate >= '20030101'
GROUP BY country, YEAR(hiredate)
HAVING COUNT(*) > 1
ORDER BY country , yearhired DESC;

SELECT country, YEAR(hiredate) AS yearhired
FROM HR.Employees
WHERE yearhired >= 2003;--fail



