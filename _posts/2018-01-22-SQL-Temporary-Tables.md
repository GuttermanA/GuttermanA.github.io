---
title:  "SQL: Temporary Tables and Query Efficiency"
date:   2018-01-22 09:15:00
categories: SQL, Temporary Tables, StackExchange
published: true
future: true
layout: post
---

During my 3 years working with SQL, one of the most effective tools I learned for increasing query execution speed is the temporary table. Temp tables are created from existing tables in a database and can be generally used to process intermediate results in more complex queries. They are unique in the respect that they are created in a temp database parallel to the working databases and are deleted after the connection to the database is closed.

Why break one query into multiple with temp tables you ask?

As a database grows in size, queries that were previously quick to execute may begin to slow down due to factors such as complex joins or structure of the database. Adding temp tables to more complex queries can significantly improve performance due to the way every SQL database engine attempts to optimize queries and create the most efficient execution plan. Essentially, when your query is sent to the database, it determines the best way to access the data requested before retrieving it. For example, in a query with a simple join between 2 tables with an [index](https://stackoverflow.com/questions/2955459/what-is-an-index-in-sql) each, there are 4 possible ways to access the data. You can imagine as the query gets more complex, the ways to access the data increases exponentially. A good analogy for this comes from a user on [StackExchange](https://dba.stackexchange.com/questions/83505/massive-joins-vs-updating-temp-table): "Think of it like eating a pie - you can probably eat a pretty good-sized piece in one sitting, but if your goal is to eat the whole pie, you might want to spread it out across multiple settings[sic]."

If you want more information on how database engines create execution plans and return data see this excellent [blog post](http://rusanu.com/2013/08/01/understanding-how-sql-server-executes-a-query/).

Temp tables can increase speed in some cases where complex joins and indexing create a huge amount of ways for the database workers to access the data.

To demonstrate their effectiveness, I used the [StackExchange Data Explorer](http://data.stackexchange.com/) for StackOverflow. It is a free web tool that you can use to query and analyze post and user data from StackExchange without having to download the data dump and import it into your own database system. The Data Explorer was incredibly useful for my purposes as it has multiple tables with several million rows. Many of the most popular queries on the main Queries page of the Data Explorer are totally unoptimized, giving me the perfect place to prove the performance gains from temp tables.

![StackExchange]({{ "/assets/01-2018-SQL-Post/StackExchange-Data-home.png" | absolute_url }})

## Tested Queries

**Basic Temp Table Query Structure**

![Basic Query Structure]({{ "/assets/01-2018-SQL-Post/Temp-Table-Basic-Query-Structure.png" | absolute_url }})

 **Notes:**
* Running the query directly from the link below will instantly return the result set due to the server cache. To see the true query runtime, use my slightly updated versions below.
* The query execution return times will vary depending on the load on the StackExchange servers at that time, however the queries marked efficient will run faster. The differences between runtimes will decrease as server load decreases based upon testing.
* Each temp table query is written with MS SQL Server Syntax used by StackExchange Data Explorer

The first query I tested was Users by Popular Questions Ratio found [here](http://data.stackexchange.com/stackoverflow/query/2777/users-by-popular-question-ratio). The result set contains the top 100 users with at least 10 popular questions, by popular question ratio (popular questions/questions). The query is structured with two subqueries with aggregate functions joined to the master table. Not only do I think the SQL is not very readable, speed gains can be made using temp tables in place of the subqueries.

{% highlight sql linenos %}
--100 rows returned in 8490 ms at 9:00AM

SELECT top 100
  Users.Id AS [User Link],
  BadgeCount AS [Popular Questions],
  QuestionCount AS [Total Questions],
  CONVERT(float, BadgeCount)/QuestionCount AS [Ratio]
from Users
INNER JOIN (
  -- Popular Question badges for each user subquery
  SELECT
    UserId,
    count(Id) AS BadgeCount
  from Badges
  where Name = 'Popular Question'
  GROUP BY UserId
) AS Pop on Users.Id = Pop.UserId
INNER JOIN (
  -- Questions by each user subquery
  SELECT
    OwnerUserId,
    count(Id) AS QuestionCount
  from posts
  where PostTypeId = 1
  GROUP BY OwnerUserId
) AS Q on Users.Id = Q.OwnerUserId
where BadgeCount >= 10
order by [Ratio] desc;
{% endhighlight %}

In my optimized version of the query, I took the Popular Question badges for each user and Questions by each user subqueries and turned them into temporary tables. Each temp table statement is processed in order and stored into a table after the INTO statement with a leading #. This tables can then be joined and manipulated in the same query in any way you see fit, like regular tables.

{% highlight sql linenos %}
--100 rows returned in 5959 ms at 9:00AM

-- Popular Question badges for each user Temp Table
SELECT
  UserId,
  count(Id) AS BadgeCount
INTO #Pop
FROM Badges
WHERE Name = 'Popular Question'
GROUP BY UserId

-- Questions by each user Temp Table
SELECT
  OwnerUserId,
  count(Id) AS QuestionCount
INTO #Q
FROM posts
WHERE PostTypeId = 1
GROUP BY OwnerUserId

SELECT top 100
  Users.Id AS [User Link],
  BadgeCount AS [Popular Questions],
  QuestionCount AS [Total Questions],
  CONVERT(float, BadgeCount)/QuestionCount AS [Ratio]
FROM Users
INNER JOIN #Pop Pop on Users.Id = Pop.UserId
INNER JOIN #Q Q on Users.Id = Q.OwnerUserId
WHERE BadgeCount >= 10
order by [Ratio] desc;
{% endhighlight %}

I also tested another query, Top 50 Most Prolific Editors found [here](http://data.stackexchange.com/stackoverflow/query/6627/top-50-most-prolific-editors). The result set contains the top 50 post editors where the user was the most recent editor. In this query, 3 subqueries are used in the SELECT statement to return aggregate values of edits by a user. Again, I think this does not read very well and has the added disadvantage of being slower than temp tables would be.

{% highlight sql linenos %}
--50 rows returned in 33500 ms at 9:00AM

SELECT TOP 50
  Id AS [User Link],
  --Question Edits subquery
  (
      SELECT COUNT(id)
      FROM Posts
      WHERE
          PostTypeId = 1 AND
          LastEditorUserId = Users.Id AND
          OwnerUserId = Users.Id
  ) AS QuestionEdits,
  --Answer Edits subquery
  (
      SELECT COUNT(id) FROM Posts
      WHERE
          PostTypeId = 2 AND
          LastEditorUserId = Users.Id AND
          OwnerUserId = Users.Id
  ) AS AnswerEdits,
  --Total Edits subquery
  (
      SELECT COUNT(id) FROM Posts
      WHERE
          LastEditorUserId = Users.Id AND
          OwnerUserId = Users.Id
  ) AS TotalEdits
FROM Users
{% endhighlight %}

In my Temp Table version, I turned the QuestionEdits and AnswerEdits subqueries into temp tables, which had the added benefit of being able to remove TotalEdits as a subquery, and just used the counts from Question and Answer Edits sum to find the total.

{% highlight sql linenos %}
-- 50 rows returned in 16224 ms at 9:00AM

--Question Edits temp table
SELECT
  COUNT(id)
  QuestionEdits,
  LastEditorUserId,
  OwnerUserId
INTO #QuestionEdits
FROM Posts
WHERE
PostTypeId = 1
GROUP BY LastEditorUserId, OwnerUserId

--Answer Edits temp table
SELECT
  COUNT(id) AnswerEdits,
  LastEditorUserId,
  OwnerUserId
INTO #AnswerEdits
FROM Posts
WHERE
PostTypeId = 2
GROUP BY LastEditorUserId, OwnerUserId

SELECT TOP 50
  Users.Id AS [User Link],
  QE.QuestionEdits,
  AE.AnswerEdits,
  TotalEdits = QE.QuestionEdits +  AE.AnswerEdits
FROM Users

INNER JOIN #QuestionEdits QE ON
QE.LastEditorUserId = Users.Id
AND QE.OwnerUserId = Users.Id

INNER JOIN #AnswerEdits AE ON
AE.LastEditorUserId = Users.Id
AND AE.OwnerUserId = Users.Id

ORDER BY TotalEdits DESC
{% endhighlight %}


In these test cases, the speed gains are significant when the servers are under load. Moreover, as query complexity increases, so do the speed gains from temp tables. The test cases above are very basic compared to some of the queries I wrote while working for the City of New York. One case where temp tables were required to more efficiently process results is so parse and convert address data into postal service standard. Any kind of data mutation will bring significant speed gains if passed through the intermediate step of a temp table. In a future blog post hopefully I will be able to demonstrate this with a more complete set of tests including data mutation.

Currently I am studying Ruby at Flatiron School and I think it will be helpful to quickly go over the ways in which you can integrate custom SQL in your own Rails application.

While many SQL needs in ruby can be fulfilled by ActiveRecord, there may come a time where you need to answer a question that does not fall within the methods provided by the Gem. Custom SQL can be used with the SQLite Gem with the .execute method, with the PostGreSQL Gem using .exec or .exec_params, or through ActiveRecord with find_by_sql method.

 **SQLite**
{% highlight ruby %}
sql = <<-SQL
  "SELECT *
  FROM table
  WHERE attribute1 = ?
  AND attribute2 = ?"
  SQL

DB_connection.execute(sql, parameter1, parameter2)
{% endhighlight %}

 **PostGreSQL**
{% highlight ruby %}
sql = <<-SQL
  "SELECT *
  FROM table
  WHERE attribute1 = $1
  AND attribute2 = $2"
  SQL

DB_connection.exec_params(sql, [parameter1, parameter2])
{% endhighlight %}

 **ActiveRecord**
{% highlight ruby %}
Client.find_by_sql("SELECT * FROM clients
  INNER JOIN orders ON clients.id = orders.client_id
  ORDER BY clients.created_at desc")
# =>  [
#   #<Client id: 1, first_name: "Lucas" >,
#   #<Client id: 2, first_name: "Jan" >,
#   ...
# ]
{% endhighlight %}

Please note that the SQL syntax for using temp tables will vary depending on your database engine. For more information:

* [SQLite](https://stackoverflow.com/questions/26491230/sqlite-query-results-into-a-temp-table)
* [PostGreSQL](https://stackoverflow.com/questions/15691243/creating-temporary-tables-in-sql)
* Syntax used above - [MS SQL Server][1]

[1]: https://technet.microsoft.com/en-us/library/ms177399(v=sql.105).aspx
