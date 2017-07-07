/*
Lesson 1 _ Filtrando e organizando dados

*/

SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE country = N'USA';

SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE region = N'WA';

SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE region <> N'WA';

SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE region <> N'WA'
OR region IS NULL;

declare @dt datetime
set @dt = '20160101'

--a instru��o abaixo n�o � um search argument pois usa uma fun��o em um campo
SELECT orderid, orderdate, empid
FROM Sales.Orders
WHERE COALESCE(shippeddate, '19000101') = COALESCE(@dt, '19000101');

--prefira a op��o abaixo, pois � um search argument e por isso tem uma performance melhor.
SELECT orderid, orderdate, empid
FROM Sales.Orders
WHERE shippeddate = @dt
OR (shippeddate IS NULL AND @dt IS NULL);

--Como a coluna � unicode e a condi��o n�o, o SQL converte implicitamente. 
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = 'Davis';

--Prefira a solu��o abaixo, pois em alguns casos pode ter uma melhor performance
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = N'Davis';

/*
Caracteres curingas

% - qualquer cadeia de caracteres, incluindo uma vazia ('D%': qualquer coisa que comece com "D")
_ - qualquer caractere ('_D%' : qualquer texto cuja segunda letra seja "D")
[<lista de carcteres>] - ('[AC]% : textos cuja primeira letra seja "A" ou "C")
[<sequ�ncia de caracteres>] - um caractere de uma sequ�ncia ('[0-9]%' : textos que comecem com um d�gito
[^<lista ou sequ�ncia de caracteres>] - um caractere que n�o est� em uma sequ�ncia ou lista ('[^0-9]%' : textos que n�o comecem com um d�gito)

*/

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

--Se precisar procurar no texto por um caractere que seja curinga, use a palavra-chave ESCAPE. Veja a diferen�a:
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'%';

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'%' ESCAPE '%';

/*

Quando usa-se o like com um prefixo, como em "ABC%" o sql ainda consegue usar a indexa��o de forma eficiente.
Usar um carctere curinga como prefixo faz com que o SQL n�o consiga usar o �ndice de forma eficiente, e pode inpactar na performance.

Lembre se que "LIKE 'ABC%' � um search argument, enquanto 'LEFT(col,3) = 'ABC' n�o �.
*/

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate = '02/12/07';

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate = '20070212';--e forma � independente de linguagem, e por isso, prefer�vel.

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE YEAR(orderdate) = 2007 AND MONTH(orderdate) = 2; -- n�o � um search argument

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate >= '20070201' AND orderdate < '20070301';--  � um search argument

/*
Lesson 2 - Organizando dados

N�o h� nenhuma garantia da ordem dos dados a menos que seja especificada uma cl�usula ORDER BY
 
*/

SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA';

SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY city;

SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY city DESC;

SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY city, empid;

SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY 4, 1;-- n�o � uma boa pr�tica

SELECT empid, city
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY birthdate;

SELECT DISTINCT city
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY birthdate;

SELECT DISTINCT city
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY city;

SELECT empid, firstname, lastname, city, MONTH(birthdate) AS birthmonth
FROM HR.Employees
WHERE country = N'USA' AND region = N'WA'
ORDER BY birthmonth;

--O  SQL padr�o suporta as op��es NULLS FIRST e NULLS LAST, mas o T-SQL n�o. Voc� pode atingir o mesmo objetivo usando o CASE

/*
 Lesson 3  - Filtrando dados com TOP e OFFSET-FETCH

*/

SELECT TOP (3) orderid, orderdate, custid, empid -- T-SQL suporta o n�mero de linhas sem par�nteses, mas apenas por compatibilidade de vers�es anteriores, a sintaxe correta � com par�nteses.
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

DECLARE @n AS BIGINT = 5;
SELECT TOP (@n) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY (SELECT NULL);--se realmente quiser 3 linhas quasquer, use o SELECT NULL para que quem leia o c�digo saiba que foi intencional.

SELECT TOP (3) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (3) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

SELECT TOP (3) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 0 ROWS FETCH FIRST 25 ROWS ONLY;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET 50 ROWS;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY (SELECT NULL)
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;

DECLARE @pagesize AS BIGINT = 25, @pagenum AS BIGINT = 3;
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC, orderid DESC
OFFSET (@pagesize - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY;

