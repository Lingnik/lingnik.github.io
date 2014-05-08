---
layout: post
title:  "A Fast(er) Transact-SQL String Split() Function"
date:   2009-10-16 11:12:00
---

**UPDATE 2014-05-07:** Aaron Bertrand put this topic to bed [here](http://sqlperformance.com/2012/07/t-sql-queries/split-strings).

Microsoft SQL Server 2005 has no SPLIT(InputString,Delimiter) function. For example, if you had some CSV (comma-separated-values) data like 'Toyota,Tacoma,2009,$20000', there is no built-in way in Transact-SQL to split that up into its discrete parts. There are other solutions out there that attempt to split this data up for you into either a table like (ColumnNumber Integer,ColumnData VarChar) with each row being a column in your single string, and then letting you PIVOT those into columns (CarMfg,CarMake,CarYear,CarCost).

Some of the other functions out there that I could find would iterate through the entire string character-by-character, seeking the next instance of @Delimiter within @InputString, marking that point, and using SUBSTRING() to go backwards in the string to the previous instance of @Delimiter to retrieve the string. Each time it found a delimiter, it would insert the column value and column number into a table variable @ResultTable.

This works for small strings, but as the length of each column within your string grows, this method becomes inefficient, especially when you're working with a large number of strings. My solution addresses this:

    DECLARE @ResultTable TABLE (Col Integer, Val VarChar(255));
    DECLARE @InputString VarChar(8000);
    DECLARE @Delimiter VarChar(50);
    SET @InputString = '1,2,3,4,5,6,7,8,9,0';
    SET @Delimiter = ',';
    ----
    DECLARE @Start Integer, @NextDelimiter Integer, @Length Integer, @Number Integer;
    SET @InputString = @InputString %2B @Delimiter;
    SET @Number = 1;
    SET @Start = 1;
    SET @Length = CHARINDEX(@Delimiter,@InputString,0) - 1;
    WHILE @Start

Here are my results from testing these two methods:

|-
|Fields|Rows|FieldLength|Intarweb Method|My Method|
|-
|15|50000|1|18s|17s|
|15|50000|10|26s|17s|
|15|50000|100|149s|22s|
|100|50000|1|61s|56s|
|100|50000|10|200s|116s|

As you can see, when the size of each column is the same, there really is no benefit, and as the number of columns grows, it does so exponentially. However, with the method described earlier, as the size of each column grows, it just gets ugly.  
