---
layout: post
title:  "SQL: Temporary Tables and Query Efficiency"
date:   2018-01-22 09:15:00
categories: SQL, Temporary Tables, StackExchange
published: true
future: true
---


During my 3 years working with SQL, one of the most effective tools I learned for increasing query efficiency Temporary Table. Temporary Tables are created from existing tables in a database and your generally used to process intermediate results in more complex queries. They are unique in the respect that they are created in a temp database parallel to the working databases and are deleted after the connection to the database is closed.

Why use Temp Tables when queries against main tables would suffice you ask? As a database grows in size, queries that were previously quick to execute may begin to slow down due to factors such as complex joins or structure of joined tables and the database. Adding Temp Tables to more complex queries can significantly improve performance due to the way every SQL database engine attempts to optimize queries and create the most efficient execution plan. Essentially, when your query is sent to the database, it determines the best way to access the data requested before retrieving it. For example, in a query with a simple join between 2 tables with an [index](https://stackoverflow.com/questions/2955459/what-is-an-index-in-sql) each, there are 4 ways to access the data. You can imagine as the query gets more complex, the ways to access the data increases exponentially. A good analogy for this comes from a user on StackExchange: "Think of it like eating a pie - you can probably eat a pretty good-sized piece in one sitting, but if your goal is to eat the whole pie, you might want to spread it out across multiple settings[sic]." --[Aaaron Bertrand](https://dba.stackexchange.com/questions/83505/massive-joins-vs-updating-temp-table)

If you want more information on how database engines create execution plans and return data see this excellent [blog post](http://rusanu.com/2013/08/01/understanding-how-sql-server-executes-a-query/).

To demonstrate their effectiveness, I used the StackExchange Data Explorer. It is a free web tool that you can use to query and analyze post and user data from stack exchange without having to download the data dump and import it into your own database system. The Data Explorer was incredibly useful for my purposes as it has multiple tables with several million rows. Many of the most popular queries on the main Queries page of the Data Explorer are totally unoptimized, giving me the perfect place to prove the performance gains from Temp Tables.

The first unoptimized query I tested was Users by Popular Questions Ratio found [here](http://data.stackexchange.com/stackoverflow/query/2777/users-by-popular-question-ratio). The result set contains the top 100 users with at least 10 popular questions, by popular question ratio (popular questions/questions).

NOTES:
--Running the query directly from the link below will instantly return the result set due to the server cache. To see the full query run time, copy the query into a new query window and change one of the aliases of the columns(AS)
--The query execution return times will vary depending on the load on the StackExchange servers at that time, however the queries marked efficient will run faster.

{% highlight sql linenos %}
--100 rows returned in 8490 ms

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

In my optimized version of the query, I took the Popular Question badges for each user and Questions by each user subqueries and turned them into temporary tables:

{% highlight sql linenos %}
--100 rows returned in 5959 ms

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

As you can see, the return speed is significantly faster in the Temp Table version, at 5959 ms, compared to the unoptimized version, at 8490 ms. This is a 35% gain in speed.

I also optimized another query, Top 50 Most Prolific Editors found [here](http://data.stackexchange.com/stackoverflow/query/6627/top-50-most-prolific-editors). The result set contains the top 50 post editors where the user was the most recent editor.

{% highlight sql linenos %}
--50 rows returned in 33500 ms

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
  Total Edits subquery
  (
      SELECT COUNT(id) FROM Posts
      WHERE
          LastEditorUserId = Users.Id AND
          OwnerUserId = Users.Id
  ) AS TotalEdits
FROM Users
{% endhighlight %}

In my Temp Table version, I turned the QuestionEdits and AnswerEdits subqueries into Temp Tables, which had the added benefit of being able to remove TotalEdits as a subquery, and just used the counts from Question and Answer Edits sum to find the total:

{% highlight sql linenos %}
-- 50 rows returned in 16224 ms

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

The unoptimized version of this query runs in 33500 ms, compared to 16224 ms in the optimized version. That is a 51% increase in efficiency.

While many SQL needs in ruby can be fulfilled by ActiveRecord, there may come a time where you need to answer a question that does not fall within the methods provided by the Gem. Custom SQL can be used with the SQLite Gem by passing the SQL through .execute method or through ActiveRecord with find_by_sql method.


SQLite
{% highlight ruby %}
DB.execute("SELECT * FROM table WHERE attribute = ?" , parameter)
{% endhighlight %}

ActiveRecord
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

Please note that the syntax for using Temp Tables will vary depending on your database engine. For more information:

* [SQLite](https://stackoverflow.com/questions/26491230/sqlite-query-results-into-a-temp-table)
* [PostGreSQL](https://stackoverflow.com/questions/15691243/creating-temporary-tables-in-sql)
* Syntax used above - [MS SQL Server](https://technet.microsoft.com/en-us/library/ms177399(v=sql.105).aspx)
