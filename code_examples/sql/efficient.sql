set nocount on

CREATE TABLE #VoteStats (PostId int, up int, down int)

insert #VoteStats
select
    PostId,
    up = sum(case when VoteTypeId = 2 then 1 else 0 end),
    down = sum(case when VoteTypeId = 3 then 1 else 0 end)
from Votes
where VoteTypeId in (2,3)
group by PostId

set nocount off


select top 100 p.id as [Post Link] , up, down from #VoteStats
join Posts p on PostId = p.Id
where down > (up * 0.5) and p.CommunityOwnedDate is null and p.ClosedDate is null
order by up desc


/*Stack Overflow Users by Popular Questions*/
--100 rows returned in 7992 ms

-- Users by Popular Question ratio
-- (only users with at least 10 Popular Questions)

-- Popular Question badges for each user Temp Table
select
  UserId,
  count(Id) as BadgeCount
INTO #Pop
from Badges
where Name = 'Popular Question'
group by UserId

-- Questions by each user Temp Table
select
  OwnerUserId,
  count(Id) as QuestionCount
INTO #Q
from posts
where PostTypeId = 1
group by OwnerUserId


select top 100
  Users.Id as [User Link],
  BadgeCount as [Popular Questions],
  QuestionCount as [Total Questions],
  CONVERT(float, BadgeCount)/QuestionCount as [Ratio]
from Users
inner join #Pop Pop on Users.Id = Pop.UserId
inner join #Q Q on Users.Id = Q.OwnerUserId
where BadgeCount >= 10
order by [Ratio] desc;


-- Top 50 Most Prolific Editors
-- Shows the top 50 post editors, where the user was the most recent editor
-- (meaning the results are conservative compared to the actual number of edits).
-- 50 rows returned in 16224 ms

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
