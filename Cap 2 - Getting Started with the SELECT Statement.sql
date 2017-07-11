/*

Lesson 1

A cl�usula FROM � a primeira a ser avaliada logicamente e tem dois pap�is principais:
 
 - � a cl�usula onde voc� indica as tabelas que voc� quer consultar.
 - � a cl�usula onde voc� pode aplicar operadores de tabela como "joins".

Como exemplo b�sico, presumindo que voc� esteja conectado no database exemplo TSQL2012, a consulta abaixo usa a cl�usula FROM para especificar que a tabela que est� sendo consultada � a "Employees" do SCHEMA "HR"

*/

SELECT empid, firstname, lastname
FROM HR.Employees;

*/

Voc� pode usar um ALIAS em uma tabela tamb�m

*/

SELECT E.empid, firstname, lastname
FROM HR.Employees AS E;


*/


A cl�usula SELECT de uma consulta tem dois pap�is principais:

 - Avaliar as express�es que definem os atributos de uma consulta, atribuindo a eles ALIAS se necess�rio.
 - Usando uma cl�sula DISTINCT, voc� pode eliminar linhas duplicadas no resultado.
 

Apesar de n�o ser necess�rio, para atribuir um ALIAS a um atributo, prefira usar o "AS" para deixar o c�digo mais leg�vel e menos suscet�vel a erros.


Delimitadores:
"Sales"."Orders"
[Sales].[Orders]

Quando o identificador � regular, delimitadores s�o opcionais.
Regras para um identificador regular:
 - Deve come�ar com uma letra de A a Z (mai�scula ou min�scula), sublinhado (_), arroba (@) ou sustenido (#).
 - Caracteres subsequentes podem incluir letras, arroba, cifr�o ($), n�meros ou sublinhado.
 - O identificador n�o pode ser uma palavra-chave, n�o pode ter espa�o nem caracteres suplementares.


 Lesson 2


 Data types restringem os dados que s�o suportados, al�m de encapsular o comportamento, expondo-os para operadores.
 T_SQL suporta v�rias fun��es nativas que voc� pode usar para manipular dados.
 
 SQL Server suporta data types de diferentes categorias:
  - Num�rico exato (INT, NUMERIC);
  - Cadeias de caracteres (CHAR, VARCHAR);
  - Cadeias de caracteres Unicode (NCHAR, NVARCHAR);
  - Num�rico aproximado (FLOAT, REAL);
  - Cadeias bin�rias (BINARY, VARBINARY);
  - Data e hora (DATE, TIME, DATETIME2, SMALLDATETIME, DATETIME, DATETIMEOFFSET);
  - e outros;
     
Assim como um data type � uma restri��o, NOT NULL tamb�m.

Cuidado com o FLOAT e REAL. N�meros de ponto flutuante s�o aproximados, nem todos os valores podem ser expressados exatamente. 


CHAR, NCHAR e BINARY s�o fixos. VARCHAR, NVARCHAR, VARBINARY s�o din�micos.
Tipos regulares (CHAR, VARCHAR) usam apenas 1 byte e suportam apenas uma l�ngua, al�m do Ingl�s, baseado no COLLATION. Unicode (NCHAR, NVARCHAR) usa 2 bytes e suporta m�ltiplas l�nguas.


Op��es t�picas para se gerar chaves atificiais:
- Propriedade de coluna IDENTITY: Uma propriedade que gera chaves automaticamente em um atributo de um tipo num�rico de escala 0. Qualquer tipo inteiro (TINYINT,SMALLINT, INT, BIGINT) ou NUMERIC/DECIMAL de escala 0.
- Sequence object: Um objeto independente no banco de dados de onde voc� pode obter novos valores sequenciais. Assim como o IDENTITY, suiporta qualquer tipo num�rico de escala 0. Diferentemente do INDENTITY, n�o est� preso 
a uma coluna particular. Voc� pode at� requisitar um novo valor de um sequence object antes de us�-lo. Existem in�meras outras vantagens sobre o identity que ser� discutida no cap�tulo 11.
- GUIDs n�o-sequenciais: Voc� pode gerar identificadores �nicos globais n�o-sequenciais para serem armazenados em um atributo de um tipo UNIQUEIDENTIFIER. Voc� pode usar a fun��o T-SQL NEWID para gerar um GUID novo.
Voc� pode gerar de qualquer lugar, por exemplo, de um cliente usando uma aplica��o (API) que gera um novo GUID. Os GUIDs s�o garantidos ser �nicos no tempo e espa�o.  
- GUIDs sequenciais: Voc� pode usar fun��o T-SQL NEWSEQUENTIALID para gerar um GUID sequencial.
- Solu��es personalizadas: Se voc� n�o quiser usar as ferramentas nativas que o SQL Server prov�, voc� pode desenvolver sua pr�pria solu��o personalizada. O data type depende da sua solu��o. 

*/

CREATE SEQUENCE dbo.CountBy1
    START WITH 1
    INCREMENT BY 1 ;
GO

SELECT NEXT VALUE FOR dbo.CountBy1

--Fun��es de data e hora
SELECT GETDATE()
SELECT CURRENT_TIMESTAMP--igual ao GETDATE, mas esse � padr�o SQL.

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

--Fun��es de caracteres

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
--COALESCE e NULLIF s�o padr�es
--ISNULL, IIF e CHOOSE n�o s�o

SELECT COALESCE(NULL, NULL, 1)
SELECT NULLIF(1, NULL)

SELECT ISNULL(NULL, 1)
SELECT IIF( 1 > 2, 1, 2)
SELECT CHOOSE(2, 5, 6, 7, 8)

