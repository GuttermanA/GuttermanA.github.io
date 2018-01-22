/*Stack Overflow Most Controversial Comments Inneficient Example
100 rows returned in 24981 ms
*/

SELECT TOP 100
p.id AS [Post Link],
sum(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS up,
sum(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS down
FROM Votes
JOIN Posts p ON PostId = p.Id
WHERE VoteTypeId IN (2,3)
AND p.CommunityOwnedDate IS NULL
AND p.ClosedDate IS NULL
group by p.id
HAVING SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) > (SUM(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) * 0.5)



/*Stack Overflow Users by Popular Questions*/
--100 rows returned in 13702 ms

-- Users by Popular Question ratio
-- (only users with at least 10 Popular Questions)

select top 100
  Users.Id as [User Link],
  BadgeCount as [Popular Questions],
  QuestionCount as [Total Questions],
  CONVERT(float, BadgeCount)/QuestionCount as [Ratio]
from Users
inner join (
  -- Popular Question badges for each user
  select
    UserId,
    count(Id) as BadgeCount
  from Badges
  where Name = 'Popular Question'
  group by UserId
) as Pop on Users.Id = Pop.UserId
inner join (
  -- Questions by each user
  select
    OwnerUserId,
    count(Id) as QuestionCount
  from posts
  where PostTypeId = 1
  group by OwnerUserId
) as Q on Users.Id = Q.OwnerUserId
where BadgeCount >= 10
order by [Ratio] desc;

-- Top 50 Most Prolific Editors
-- Shows the top 50 post editors, where the user was the most recent editor
-- (meaning the results are conservative compared to the actual number of edits).
--50 rows returned in 33500 ms

SELECT TOP 50
    Id AS [User Link],
    (
        SELECT COUNT(*) FROM Posts
        WHERE
            PostTypeId = 1 AND
            LastEditorUserId = Users.Id AND
            OwnerUserId = Users.Id
    ) AS QuestionEdits,
    (
        SELECT COUNT(*) FROM Posts
        WHERE
            PostTypeId = 2 AND
            LastEditorUserId = Users.Id AND
            OwnerUserId = Users.Id
    ) AS AnswerEdits,
    (
        SELECT COUNT(*) FROM Posts
        WHERE
            LastEditorUserId = Users.Id AND
            OwnerUserId = Users.Id
    ) AS TotalEdits
    FROM Users
    ORDER BY TotalEdits DESC
