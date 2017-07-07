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

--a instrução abaixo não é um search argument pois usa uma função em um campo
SELECT orderid, orderdate, empid
FROM Sales.Orders
WHERE COALESCE(shippeddate, '19000101') = COALESCE(@dt, '19000101');

--prefira a opção abaixo, pois é um search argument e por isso tem uma performance melhor.
SELECT orderid, orderdate, empid
FROM Sales.Orders
WHERE shippeddate = @dt
OR (shippeddate IS NULL AND @dt IS NULL);

--Como a coluna é unicode e a condição não, o SQL converte implicitamente. 
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = 'Davis';

--Prefira a solução abaixo, pois em alguns casos pode ter uma melhor performance
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = N'Davis';

/*
Caracteres curingas

% - qualquer cadeia de caracteres, incluindo uma vazia ('D%': qualquer coisa que comece com "D")
_ - qualquer caractere ('_D%' : qualquer texto cuja segunda letra seja "D")
[<lista de carcteres>] - ('[AC]% : textos cuja primeira letra seja "A" ou "C")
[<sequência de caracteres>] - um caractere de uma sequência ('[0-9]%' : textos que comecem com um dígito
[^<lista ou sequência de caracteres>] - um caractere que não está em uma sequência ou lista ('[^0-9]%' : textos que não comecem com um dígito)

*/

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

--Se precisar procurar no texto por um caractere que seja curinga, use a palavra-chave ESCAPE. Veja a diferença:
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'%';

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'%' ESCAPE '%';

/*

Quando usa-se o like com um prefixo, como em "ABC%" o sql ainda consegue usar a indexação de forma eficiente.
Usar um carctere curinga como prefixo faz com que o SQL não consiga usar o índice de forma eficiente, e pode inpactar na performance.

Lembre se que "LIKE 'ABC%' é um search argument, enquanto 'LEFT(col,3) = 'ABC' não é.
*/

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate = '02/12/07';

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate = '20070212';--e forma é independente de linguagem, e por isso, preferível.

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE YEAR(orderdate) = 2007 AND MONTH(orderdate) = 2; -- não é um search argument

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderdate >= '20070201' AND orderdate < '20070301';--  é um search argument

/*
Lesson 2 - Organizando dados

Não há nenhuma garantia da ordem dos dados a menos que seja especificada uma cláusula ORDER BY
 
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
ORDER BY 4, 1;-- não é uma boa prática

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

--O  SQL padrão suporta as opções NULLS FIRST e NULLS LAST, mas o T-SQL não. Você pode atingir o mesmo objetivo usando o CASE

/*
 Lesson 3  - Filtrando dados com TOP e OFFSET-FETCH

*/

SELECT TOP (3) orderid, orderdate, custid, empid -- T-SQL suporta o número de linhas sem parênteses, mas apenas por compatibilidade de versões anteriores, a sintaxe correta é com parênteses.
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
ORDER BY (SELECT NULL);--se realmente quiser 3 linhas quasquer, use o SELECT NULL para que quem leia o código saiba que foi intencional.

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

