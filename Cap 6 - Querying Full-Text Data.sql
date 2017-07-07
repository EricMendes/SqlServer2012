/*
Lesson 1: Creating Full-Text Catalogs and Indexes



Antes de usar os atributos e fun��es full-text, voc� deve criar indexes full-text dentro de cat�logos full-text. 
Depois de criar indexes full-text dentro de colunas de caracteres, voc� estar� apto a buscar por:

- Simple terms: uma ou mais palavras ou frases espec�ficas.
- Prefix terms: termos que as palavras ou frases come�am.
- Generation terms: formas flexionadas de palavras.
- Proximity terms: palavras ou frases pr�ximas de outras palavras ou frases
- Thesaurus terms: sin�nimos de uma palavra.
- Weighted terms: palavras ou frases que utilizam valores com o seu peso personalizado.
- Statistical semantic search: palavras-chave erm um documento.
- Similar documents: onde a similaridade � definida por frases-chave sem�nticas.

*/

SELECT SERVERPROPERTY('IsFullTextInstalled');

/*

Voc� pode criar full-text indexes em campos do tipo CHAR, VARCHAR, NCHAR, NVARCHAR, TEXT, NTEXT, IMAGE, XML, and VARBINARY(MAX)

Voc� pode armazenar documentos inteiros em colunas BINARY ou XML, e fazer consultas full-text nesses documentos. 
Colunas do tipo VARBINARY(MAX), IMAGE, or XML requerem uma coluna adicional para o tipo de extens�o do arquivo que voc� armazena (como .docx,.pdf, or .xlsx).
Voc� precisa de filtros adequados ao documento. S�o chamados ifilters na terminologia full-text. Voc� pode checar quais filtros est�o instalado usando os comandos abaixo:

*/

EXEC sys.sp_help_fulltext_system_components 'filter';

SELECT document_type, path
FROM sys.fulltext_document_types;

--A maioria dos filtros mais populares est�o instalado. Voc� pode baixar e instalar filtros adicionais. 
--Depois de instalar o pacote adicional, voc� precisa registrar os filtros no SQL Server usando o comando abaixo:

EXEC sys.sp_fulltext_service 'load_os_resources', 1;

--Talvez tenha que reiniciar o SQL ap�s 

SELECT lcid, name
FROM sys.fulltext_languages
ORDER BY name;

SELECT stoplist_id, name
FROM sys.fulltext_stoplists;

SELECT stoplist_id, stopword, language
FROM sys.fulltext_stopwords;