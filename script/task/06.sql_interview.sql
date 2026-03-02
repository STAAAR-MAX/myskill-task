-- Write a query to retrieve the count of companies that have posted duplicate job listings.
SELECT
  COUNT(*) AS duplicate_companies
FROM (
        SELECT
          company_id,
          COUNT(*) nr
        FROM job_listings
        GROUP BY company_id
      )t
WHERE nr >1
---------------------------------------------------------------------------------------------------------------------------
--Write a query that outputs the name of each credit card and the difference in the number of issued cards 
-- between the month with the highest issuance cards and the lowest issuance. 
-- Arrange the results based on the largest disparity.
SELECT
  card_name,
  MAX(issued_amount) - MIN(issued_amount) diff
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY diff DESC
---------------------------------------------------------------------------------------------------------------------------

/* 
Write a query to obtain a breakdown of the time spent sending vs. opening 
snaps as a percentage of total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.
*/
WITH CTE_sumarize AS (
SELECT
  age_bucket,
  SUM(CASE WHEN activity_type = 'send' THEN time_spent ELSE 0 END) sending,
  SUM(CASE WHEN activity_type = 'open' THEN time_spent ELSE 0 END) opening
FROM activities a
LEFT JOIN age_breakdown b
ON a.user_id = b.user_id
WHERE activity_type != 'chat'
GROUP BY age_bucket
)
SELECT
  age_bucket,
  ROUND((sending/(sending+opening))*100.0,2) AS pct_send,
  ROUND((opening/(sending+opening))*100.0,2) AS pct_open
FROM CTE_sumarize
