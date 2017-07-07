/*
Lesson 1: Returning Results As XML with FOR XML


& (ampersand) &amp;
" (quotation mark) &quot;
< (less than) &lt;
> (greater than) &gt;
' (apostrophe) &apos;


Alternativamente você pode usar o XML CDATA <![CDATA[...]]>, substituindo os três pontos por qualquer caractere.


Prólogo: <?xml version="1.0" encoding="ISO-8859-15"?>.

<?Instruções de processamento?>.

<!-- Comentários -->.

A diferença entre um fragmento XML e um documento XML é que um documento tem um único nó raiz.

Documento XML:
<CustomersOrders>
<Customer custid="1" companyname="Customer NRZBB">
<Order orderid="10692" orderdate="2007-10-03T00:00:00" />
<Order orderid="10702" orderdate="2007-10-13T00:00:00" />
<Order orderid="10952" orderdate="2008-03-16T00:00:00" />
</Customer>
<Customer custid="2" companyname="Customer MLTDN">
<Order orderid="10308" orderdate="2006-09-18T00:00:00" />
<Order orderid="10926" orderdate="2008-03-04T00:00:00" />
</Customer>
</CustomersOrders>

Fragmento XML:
<Customer custid="1" companyname="Customer NRZBB">
<Order orderid="10692" orderdate="2007-10-03T00:00:00" />
<Order orderid="10702" orderdate="2007-10-13T00:00:00" />
<Order orderid="10952" orderdate="2008-03-16T00:00:00" />
</Customer>
<Customer custid="2" companyname="Customer MLTDN">
<Order orderid="10308" orderdate="2006-09-18T00:00:00" />
<Order orderid="10926" orderdate="2008-03-04T00:00:00" />
</Customer>



<xsd:schema targetNamespace="TK461-CustomersOrders" xmlns:schema="TK461-CustomersOrders"
xmlns:xsd=http://www.w3.org/2001/XMLSchema
xmlns:sqltypes=http://schemas.microsoft.com/sqlserver/2004/sqltypes
elementFormDefault="qualified">
<xsd:import namespace=http://schemas.microsoft.com/sqlserver/2004/sqltypes
schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd"
/>
	<xsd:element name="Customer">
		<xsd:complexType>
			<xsd:sequence>
				<xsd:element name="custid" type="sqltypes:int" />
				<xsd:element name="companyname">
					<xsd:simpleType>
						<xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033"
						sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth"
						sqltypes:sqlSortId="52">
							<xsd:maxLength value="40" />
						</xsd:restriction>
					</xsd:simpleType>
				</xsd:element>
				<xsd:element ref="schema:Order" minOccurs="0" maxOccurs="unbounded" />
			</xsd:sequence>
		</xsd:complexType>
	</xsd:element>
	<xsd:element name="Order">
		<xsd:complexType>
			<xsd:sequence>
				<xsd:element name="orderid" type="sqltypes:int" />
				<xsd:element name="orderdate" type="sqltypes:datetime" />
			</xsd:sequence>
		</xsd:complexType>
	</xsd:element>
</xsd:schema>

*/
SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE country = N'USA'
FOR XML RAW
--cada coluna vira um elemento XML, e colunas viram atributos.


SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE country = N'USA'
FOR XML AUTO
--idem ao anterior, mas ao invés do elemento se chamar "row", dá o nome da tabela.

SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE country = N'USA'
FOR XML AUTO, ELEMENTS;
--Elements transforma a linha em um nó e as colunas em elementos-filho

SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE country = N'USA'
FOR XML AUTO, ELEMENTS, ROOT;
--Cria um nó raiz para o resultado.

SELECT empid, firstname, lastname, country, region, city
FROM HR.Employees
WHERE country = N'USA'
FOR XML AUTO, ELEMENTS, ROOT,
XMLSCHEMA('Employees');
--Gera também o XSD

SELECT Customer.custid AS [@custid],
Customer.companyname AS [companyname]
FROM Sales.Customers AS Customer
WHERE Customer.custid <= 2
ORDER BY Customer.custid
FOR XML PATH ('Customer'), ROOT('Customers');


DECLARE @DocHandle AS INT;
DECLARE @XmlDocument AS NVARCHAR(1000);
SET @XmlDocument = N'
<CustomersOrders>
	<Customer custid="1">
	<companyname>Customer NRZBB</companyname>
	<Order orderid="10692">
		<orderdate>2007-10-03T00:00:00</orderdate>
	</Order>
	<Order orderid="10702">
		<orderdate>2007-10-13T00:00:00</orderdate>
	</Order>
	<Order orderid="10952">
		<orderdate>2008-03-16T00:00:00</orderdate>
	</Order>
	</Customer>
	<Customer custid="2">
	<companyname>Customer MLTDN</companyname>
	<Order orderid="10308">
		<orderdate>2006-09-18T00:00:00</orderdate>
	</Order>
	<Order orderid="10926">
		<orderdate>2008-03-04T00:00:00</orderdate>
	</Order>
	</Customer>
</CustomersOrders>';
-- Create an internal representation
EXEC sys.sp_xml_preparedocument @DocHandle OUTPUT, @XmlDocument;
-- Attribute-centric mapping
SELECT *
FROM OPENXML (@DocHandle, '/CustomersOrders/Customer',1)
WITH (custid INT,
companyname NVARCHAR(40));
-- Element-centric mapping
SELECT *
FROM OPENXML (@DocHandle, '/CustomersOrders/Customer',2)
WITH (custid INT,
companyname NVARCHAR(40));
-- Attribute- and element-centric mapping
-- Combining flag 8 with flags 1 and 2
SELECT *
FROM OPENXML (@DocHandle, '/CustomersOrders/Customer',11)
WITH (custid INT,
companyname NVARCHAR(40));
-- Remove the DOM
EXEC sys.sp_xml_removedocument @DocHandle;
GO

/*
Lesson 2: Querying XML Data with XQuery
*/

DECLARE @x AS XML;
SET @x=N'
<root>
<a>1<c>3</c><d>4</d></a>
<b>2</b>
</root>';
SELECT
@x.query('*') AS Complete_Sequence,
@x.query('data(*)') AS Complete_Data,
@x.query('data(root/a/c)') AS Element_c_Data;

DECLARE @x AS XML;
SET @x='
<CustomersOrders xmlns:co="TK461-CustomersOrders">
<co:Customer co:custid="1" co:companyname="Customer NRZBB">
<co:Order co:orderid="10692" co:orderdate="2007-10-03T00:00:00" />
<co:Order co:orderid="10702" co:orderdate="2007-10-13T00:00:00" />
<co:Order co:orderid="10952" co:orderdate="2008-03-16T00:00:00" />
</co:Customer>
<co:Customer co:custid="2" co:companyname="Customer MLTDN">
<co:Order co:orderid="10308" co:orderdate="2006-09-18T00:00:00" />
<co:Order co:orderid="10926" co:orderdate="2008-03-04T00:00:00" />
</co:Customer>
</CustomersOrders>';
-- Namespace in prolog of XQuery
SELECT @x.query('
(: explicit namespace :)
declare namespace co="TK461-CustomersOrders";
//co:Customer[1]/*') AS [Explicit namespace];
-- Default namespace for all elements in prolog of XQuery
SELECT @x.query('
(: default namespace :)
declare default element namespace "TK461-CustomersOrders";
//Customer[1]/*') AS [Default element namespace];
-- Namespace defined in WITH clause of T-SQL SELECT
WITH XMLNAMESPACES('TK461-CustomersOrders' AS co)
SELECT @x.query('
(: namespace declared in T-SQL :)
//co:Customer[1]/*') AS [Namespace in WITH clause];

/*
Alguns XQuery Data Types:
xs:boolean, xs:string, xs:QName, xs:date, xs:time, xs:datetime, xs:float, xs:double, xs:decimal, and xs:integer.

XQuery Functions:

Numeric functions ceiling(), floor(), and round()
String functions concat(), contains(), substring(), string-length(), lower-case(), and upper-case()
Boolean and Boolean constructor functions not(), true(), and false()
Nodes functions local-name() and namespace-uri()
Aggregate functions count(), min(), max(), avg(), and sum()
Data accessor functions data() and string()
SQL Server extension functions sql:column() and sql:variable()

*/

DECLARE @x AS XML;
SET @x='
<CustomersOrders>
	<Customer custid="1" companyname="Customer NRZBB">
		<Order orderid="10692" orderdate="2007-10-03T00:00:00" />
		<Order orderid="10702" orderdate="2007-10-13T00:00:00" />
		<Order orderid="10952" orderdate="2008-03-16T00:00:00" />
	</Customer>
	<Customer custid="2" companyname="Customer MLTDN">
		<Order orderid="10308" orderdate="2006-09-18T00:00:00" />
		<Order orderid="10926" orderdate="2008-03-04T00:00:00" />
	</Customer>
</CustomersOrders>';
SELECT @x.query('
for $i in //Customer
return
<OrdersInfo>
{ $i/@companyname }
<NumberOfOrders>
{ count($i/Order) }
</NumberOfOrders>
<LastOrder>
{ max($i/Order/@orderid) }
</LastOrder>
</OrdersInfo>
');


/*
child:: Returns children of the current context node. This is the default axis; you can omit it. Direction is down.
descendant:: Retrieves all descendants of the context node. Direction is down.
self:: Retrieves the context node. Direction is here.
descendant-or-self:: (//) Retrieves the context node and all its descendants. Direction is here and then down.
attribute:: (@) Retrieves the specified attribute of the context node. Direction is right.
parent:: (..) Retrieves the parent of the context node. Direction is up.
*/

DECLARE @x AS XML = N'';
SELECT @x.query('(1, 2, 3) = (2, 4)'); -- true
SELECT @x.query('(5, 6) < (2, 4)'); -- false
SELECT @x.query('(1, 2, 3) = 1'); -- true
SELECT @x.query('(1, 2, 3) != 1'); -- true

DECLARE @x AS XML = N'';
SELECT @x.query('(5) lt (2)'); -- false
SELECT @x.query('(1) eq 1'); -- true
SELECT @x.query('(1) ne 1'); -- false
GO
DECLARE @x AS XML = N'';
SELECT @x.query('(2, 2) eq (2, 2)'); -- error
GO

DECLARE @x AS XML = N'
<Employee empid="2">
<FirstName>fname</FirstName>
<LastName>lname</LastName>
</Employee>
';
DECLARE @v AS NVARCHAR(20) = N'FirstName';
SELECT @x.query('
if (sql:variable("@v")="FirstName") then
/Employee/FirstName
else
/Employee/LastName
') AS FirstOrLastName;
GO

DECLARE @x AS XML;
SET @x = N'
<CustomersOrders>
	<Customer custid="1">
		<!-- Comment 111 -->
		<companyname>Customer NRZBB</companyname>
		<Order orderid="10692">
			<orderdate>2007-10-03T00:00:00</orderdate>
		</Order>
		<Order orderid="10702">
			<orderdate>2007-10-13T00:00:00</orderdate>
		</Order>
		<Order orderid="10952">
			<orderdate>2008-03-16T00:00:00</orderdate>
		</Order>
	</Customer>
	<Customer custid="2">
		<!-- Comment 222 -->
		<companyname>Customer MLTDN</companyname>
		<Order orderid="10308">
			<orderdate>2006-09-18T00:00:00</orderdate>
		</Order>
		<Order orderid="10952">
			<orderdate>2008-03-04T00:00:00</orderdate>
		</Order>
	</Customer>
</CustomersOrders>';
SELECT @x.query('for $i in CustomersOrders/Customer/Order
let $j := $i/orderdate
where $i/@orderid < 10900
order by ($j)[1]
return
<Order-orderid-element>
<orderid>{data($i/@orderid)}</orderid>
{$j}
</Order-orderid-element>')
AS [Filtered, sorted and reformatted orders with let clause];


/*
Lesson 3: Using the XML Data Type
*/


