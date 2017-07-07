/*
Lesson 1: Creating Full-Text Catalogs and Indexes



Antes de usar os atributos e funções full-text, você deve criar indexes full-text dentro de catálogos full-text. 
Depois de criar indexes full-text dentro de colunas de caracteres, você estará apto a buscar por:

- Simple terms: uma ou mais palavras ou frases específicas.
- Prefix terms: termos que as palavras ou frases começam.
- Generation terms: formas flexionadas de palavras.
- Proximity terms: palavras ou frases próximas de outras palavras ou frases
- Thesaurus terms: sinônimos de uma palavra.
- Weighted terms: palavras ou frases que utilizam valores com o seu peso personalizado.
- Statistical semantic search: palavras-chave erm um documento.
- Similar documents: onde a similaridade é definida por frases-chave semânticas.

*/

SELECT SERVERPROPERTY('IsFullTextInstalled');

/*

Você pode criar full-text indexes em campos do tipo CHAR, VARCHAR, NCHAR, NVARCHAR, TEXT, NTEXT, IMAGE, XML, and VARBINARY(MAX)

Você pode armazenar documentos inteiros em colunas BINARY ou XML, e fazer consultas full-text nesses documentos. 
Colunas do tipo VARBINARY(MAX), IMAGE, or XML requerem uma coluna adicional para o tipo de extensão do arquivo que você armazena (como .docx,.pdf, or .xlsx).
Você precisa de filtros adequados ao documento. São chamados ifilters na terminologia full-text. Você pode checar quais filtros estão instalado usando os comandos abaixo:

*/

EXEC sys.sp_help_fulltext_system_components 'filter';

SELECT document_type, path
FROM sys.fulltext_document_types;

--A maioria dos filtros mais populares estão instalado. Você pode baixar e instalar filtros adicionais. 
--Depois de instalar o pacote adicional, você precisa registrar os filtros no SQL Server usando o comando abaixo:

EXEC sys.sp_fulltext_service 'load_os_resources', 1;

--Talvez tenha que reiniciar o SQL após 

SELECT lcid, name
FROM sys.fulltext_languages
ORDER BY name;

SELECT stoplist_id, name
FROM sys.fulltext_stoplists;

SELECT stoplist_id, stopword, language
FROM sys.fulltext_stopwords;