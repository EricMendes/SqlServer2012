/*

Lesson 1

A cláusula FROM é a primeira a ser avaliada logicamente e tem dois papéis principais:
 
 - É a cláusula onde você indica as tabelas que você quer consultar.
 - É a cláusula onde você pode aplicar operadores de tabela como "joins".

Como exemplo básico, presumindo que você esteja conectado no database exemplo TSQL2012, a consulta abaixo usa a cláusula FROM para especificar que a tabela que está sendo consultada é a "Employees" do SCHEMA "HR"

*/

SELECT empid, firstname, lastname
FROM HR.Employees;

*/

Você pode usar um ALIAS em uma tabela também

*/

SELECT E.empid, firstname, lastname
FROM HR.Employees AS E;


*/


A cláusula SELECT de uma consulta tem dois papéis principais:

 - Avaliar as expressões que definem os atributos de uma consulta, atribuindo a eles ALIAS se necessário.
 - Usando uma clásula DISTINCT, você pode eliminar linhas duplicadas no resultado.
 

Apesar de não ser necessário, para atribuir um ALIAS a um atributo, prefira usar o "AS" para deixar o código mais legível e menos suscetível a erros.


Delimitadores:
"Sales"."Orders"
[Sales].[Orders]

Quando o identificador é regular, delimitadores são opcionais.
Regras para um identificador regular:
 - Deve começar com uma letra de A a Z (maiúscula ou minúscula), sublinhado (_), arroba (@) ou sustenido (#).
 - Caracteres subsequentes podem incluir letras, arroba, cifrão ($), números ou sublinhado.
 - O identificador não pode ser uma palavra-chave, não pode ter espaço nem caracteres suplementares.


 Lesson 2


 Data types restringem os dados que são suportados, além de encapsular o comportamento, expondo-os para operadores.
 T_SQL suporta várias funções nativas que você pode usar para manipular dados.
 
 SQL Server suporta data types de diferentes categorias:
  - Numérico exato (INT, NUMERIC);
  - Cadeias de caracteres (CHAR, VARCHAR);
  - Cadeias de caracteres Unicode (NCHAR, NVARCHAR);
  - Numérico aproximado (FLOAT, REAL);
  - Cadeias binárias (BINARY, VARBINARY);
  - Data e hora (DATE, TIME, DATETIME2, SMALLDATETIME, DATETIME, DATETIMEOFFSET);
  - e outros;
     
Assim como um data type é uma restrição, NOT NULL também.

Cuidado com o FLOAT e REAL. Números de ponto flutuante são aproximados, nem todos os valores podem ser expressados exatamente. 


CHAR, NCHAR e BINARY são fixos. VARCHAR, NVARCHAR, VARBINARY são dinâmicos.
Tipos regulares (CHAR, VARCHAR) usam apenas 1 byte e suportam apenas uma língua, além do Inglês, baseado no COLLATION. Unicode (NCHAR, NVARCHAR) usa 2 bytes e suporta múltiplas línguas.


Opções típicas para se gerar chaves atificiais:
- Propriedade de coluna IDENTITY: Uma propriedade que gera chaves automaticamente em um atributo de um tipo numérico de escala 0. Qualquer tipo inteiro (TINYINT,SMALLINT, INT, BIGINT) ou NUMERIC/DECIMAL de escala 0.
- Sequence object: Um objeto independente no banco de dados de onde você pode obter novos valores sequenciais. Assim como o IDENTITY, suiporta qualquer tipo numérico de escala 0. Diferentemente do INDENTITY, não está preso 
a uma coluna particular. Você pode até requisitar um novo valor de um sequence object antes de usá-lo. Existem inúmeras outras vantagens sobre o identity que será discutida no capítulo 11.
- GUIDs não-sequenciais: Você pode gerar identificadores únicos globais não-sequenciais para serem armazenados em um atributo de um tipo UNIQUEIDENTIFIER. Você pode usar a função T-SQL NEWID para gerar um GUID novo.
Você pode gerar de qualquer lugar, por exemplo, de um cliente usando uma aplicação (API) que gera um novo GUID. Os GUIDs são garantidos ser únicos no tempo e espaço.  
- GUIDs sequenciais: Você pode usar função T-SQL NEWSEQUENTIALID para gerar um GUID sequencial.
- Soluções personalizadas: Se você não quiser usar as ferramentas nativas que o SQL Server provê, você pode desenvolver sua própria solução personalizada. O data type depende da sua solução. 

*/

CREATE SEQUENCE dbo.CountBy1
    START WITH 1
    INCREMENT BY 1 ;
GO

SELECT NEXT VALUE FOR dbo.CountBy1

--Funções de data e hora
SELECT GETDATE()
SELECT CURRENT_TIMESTAMP--igual ao GETDATE, mas esse é padrão SQL.

SELECT SYSDATETIME()
SELECT SYSDATETIMEOFFSET()

SELECT GETUTCDATE()
SELECT SYSUTCDATETIME()

SELECT DATEPART(DAY, GETDATE())
SELECT DATEFROMPARTS(2016, 2, 1)
SELECT DATENAME(MONTH, GETDATE())

SELECT DATETIMEFROMPARTS(2016, 2, 1, 4, 5, 6, 7)
SELECT DATETIME2FROMPARTS(2016, 2, 1, 4, 5, 6, 7, 4)
SELECT DATETIMEOFFSETFROMPARTS(2016, 2, 1, 4, 5, 6, 0, 5, 2, 7)
SELECT SMALLDATETIMEFROMPARTS(2016, 2, 1, 4, 5)
SELECT TIMEFROMPARTS(4, 5, 6, 0, 5)

SELECT EOMONTH(GETDATE(), 2)

SELECT DATEADD(MONTH, 1, GETDATE())
SELECT DATEDIFF(DAY, GETDATE(), '2016-02-09')

SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '-08:00')
SELECT TODATETIMEOFFSET(GETDATE(), '-08:00')

--Funções de caracteres

SELECT 
	empid, 
	country, 
	region, city,
	country + N',' + region + N',' + city AS location
FROM HR.Employees;

SELECT empid, country, region, city,
country + COALESCE( N',' + region, N'') + N',' + city AS location
FROM HR.Employees;

SELECT empid, country, region, city,
CONCAT(country, N',' + region, N',' + city) AS location
FROM HR.Employees;

SELECT SUBSTRING('abcde', 1, 3)
SELECT LEFT('abcde', 3)
SELECT RIGHT('abcde', 3)

SELECT CHARINDEX(' ','Itzik Ben-Gan')
SELECT LEN(N' xyz ')
SELECT DATALENGTH(N' xyz ')

SELECT REPLACE('.1.2.3.', '.', '/')
SELECT REPLICATE('0', 10)
SELECT STUFF(',x,y,z', 1, 3, 'a')

SELECT UPPER('eric')
SELECT LOWER('ERIC')
SELECT LTRIM('               eric')
SELECT RTRIM('eric               ')
SELECT FORMAT(1759, 'd10')
SELECT FORMAT(1759, '0000000000')
--CASE

SELECT productid, productname, unitprice, discontinued,
CASE discontinued
WHEN 0 THEN 'No'
WHEN 1 THEN 'Yes'
ELSE 'Unknown'
END AS discontinued_desc
FROM Production.Products;

SELECT productid, productname, unitprice,
CASE
WHEN unitprice < 20.00 THEN 'Low'
WHEN unitprice < 40.00 THEN 'Medium'
WHEN unitprice >= 40.00 THEN 'High'
ELSE 'Unknown'
END AS pricerange
FROM Production.Products;

--COALESCE
--COALESCE e NULLIF são padrões
--ISNULL, IIF e CHOOSE não são

SELECT COALESCE(NULL, NULL, 1)
SELECT NULLIF(1, NULL)

SELECT ISNULL(NULL, 1)
SELECT IIF( 1 > 2, 1, 2)
SELECT CHOOSE(2, 5, 6, 7, 8)

