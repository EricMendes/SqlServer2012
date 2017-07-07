/*
T-SQL � a implementa��o da Microsft para o dialeto SQL.
T-SQL tamb�m implementa extens�es do SQL padr�o.
Prefira implementa��es padr�o do SQL do que as implementa��es n�o-padr�o.
Ex.: "<>" e "!=" servem como operadores "diferente de" mas o primeiro � padr�o e o segundo n�o.
	 CAST tamb�m e padr�o e CONVERT n�o. Mas o CONVERT tem um argumento para o estilo que o CAST n�o suporta.
Segundo o padr�o SQL, voc� deve terminar suas instru��es com ponto-e-v�rgula. 
No T-SQL isso n�o � requerido, apenas em casos onde h� ambiguidade nos elementos do c�digo.


#Consultas b�sicas

Elimine linhas duplicadas se poss�vel no resultado de sua consulta.
*/

USE TSQL2012;

--Essa consulta provavelmente retornar� linhas duplicadas
SELECT country
FROM HR.Employees;

--Usando o distinct voc� elimina as linhas duplicadas
SELECT DISTINCT country
FROM HR.Employees;

/*
Ordem das linhas

N�o confie na ordem das linhas, se precisa de uma ordem espec�fica, use o ORDER BY.
O SQL Server usa uma s�rie de mecanismos internos para melhorar a performance da consulta, o que pode resultar em ordens 
diferentes das linhas caso n�o seja especificada a cl�usula ORDER BY. 

Na cl�usula ORDER BY voc� pode indicar o nome da coluna ou a posi��o dela na cl�usula SELECT, mas o �ltimo n�o � considerado 
uma boa pr�tica.

*/

--Com a instru��o abaixo n�o se pode prever a ordem das linhas que o SQL retornar�
SELECT empid, lastname
FROM HR.Employees;

--Usando o ORDER BY voc� garante a ordem
SELECT empid, lastname
FROM HR.Employees
ORDER BY empid;

SELECT empid, lastname
FROM HR.Employees
ORDER BY 1; --n�o � uma boa pr�tica. 


/*
Aliases

Para facilitar o entendimento, voc� pode usar aliases em colunas.
� uma boa pr�tica nomear os resultados de uma consulta.
*/

--A consulta abaixo concatena o nome e sobrenome para retornar o nome completo
SELECT empid, firstname + ' ' + lastname
FROM HR.Employees;

--Atribuindo um alias ao retorno voc� deixa mais leg�vel e facilita o entendimento
SELECT empid, firstname + ' ' + lastname AS fullname
FROM HR.Employees;


/*
O uso da terminologia correta reflete seu conhecimento, portanto, voc� deve ser esfor�ar para entender e us�-la.
	Ex. 	Campos e registros s�o f�sicos, linhas e colunas s�o l�gicos.
	Ex 2. 	NULL n�o � um valor, e sim uma marca para um valor ausente.

A ordem que o SQL Server interpreta a consulta n�o � a mesma ordem que voc� escreve a consulta.

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



