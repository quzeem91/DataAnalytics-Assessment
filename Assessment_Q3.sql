USE adashi_staging;

-- Step 1: Get customers whose last confirmed inflow is over 365 days ago
WITH inactive_customers AS (
    SELECT 
        owner_id, 
        MAX(transaction_date) AS last_transaction_date,
        DATEDIFF(CURRENT_DATE, MAX(transaction_date)) AS inactive_days
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY owner_id
    HAVING DATEDIFF(CURRENT_DATE, MAX(transaction_date)) > 365
)

-- Step 2: Join with transactions to get plan_id and with plans_plan to get type
SELECT 
    sa.plan_id,
    ic.owner_id,
    CASE 
        WHEN pp.is_regular_savings = 1 THEN 'Savings'
        WHEN pp.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    ic.last_transaction_date,
    ic.inactive_days
FROM inactive_customers ic
LEFT JOIN savings_savingsaccount sa
    ON ic.owner_id = sa.owner_id AND ic.last_transaction_date = sa.transaction_date
LEFT JOIN plans_plan pp 
    ON sa.plan_id = pp.id
WHERE pp.is_regular_savings = 1 OR pp.is_a_fund = 1
ORDER BY ic.inactive_days DESC;
