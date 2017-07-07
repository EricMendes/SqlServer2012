/*
T-SQL � a implementa��o da Microsft para o dialeto SQL.
T-SQL tamb�m implementa extens�es do SQL padr�o.
Prefira implementa��es padr�o do SQL do que as implementa��es n�o-padr�o.
Ex.: "<>" e "!=" servem como operadores "diferente de" mas o primeiro � padr�o e o segundo n�o.
	 CAST tamb�m e padr�o e CONVERT n�o. Mas o CONVERT tem um argumento para o estilo que o CAST n�o suporta.
	 Segundo o padr�o SQL, voc� deve terminar suas instru��es com ponto-e-v�rgula. No T-SQL isso n�o � requerido, apenas em casos onde h� ambiguidade nos elementos do c�digo.

*/

--Lesson 1

USE TSQL2012;

SELECT country
FROM HR.Employees;

SELECT DISTINCT country
FROM HR.Employees;

-------------------------------

SELECT empid, lastname
FROM HR.Employees;

SELECT empid, lastname
FROM HR.Employees
ORDER BY empid;

SELECT empid, lastname
FROM HR.Employees
ORDER BY 1; --n�o � uma boa pr�tica. 

-------------------------------

SELECT empid, firstname + ' ' + lastname
FROM HR.Employees;

SELECT empid, firstname + ' ' + lastname AS fullname
FROM HR.Employees;

/*
O uso da terminologia correta reflete seu conhecimento, portanto, voc� deve ser esfor�ar para entender e us�-la.
Ex. Campos e registros s�o f�sicos, linhas e colunas s�o l�gicos.
	NULL n�o � um valor, e sim uma marca para um valor ausente.
*/

-- Lesson 2

/*
Ordem das cl�usulas para uma instru��o T-SQL:

1. SELECT
2. FROM
3. WHERE
4. GROUP BY
5. HAVING
6. ORDER BY

Ordem que o SQL Server interpreta as cl�usulas:

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


--N�o confie na ordem das colunas ou linhas, se precisa de uma ordem espec�fica, use o ORDER BY.
--Sempre nomeie os resultados.
--Elimine linhas duplicadas se poss�vel no resultado de sua consulta.



