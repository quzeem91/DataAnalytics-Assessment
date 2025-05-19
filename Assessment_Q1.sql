-- Step 1: Identify high-value customers
-- Criteria: Must have at least one regular savings plan AND one investment (fund) plan

WITH high_value_customers AS (
    SELECT 
        ap.owner_id, 
        CONCAT(ac.first_name, ' ', ac.last_name) AS full_name,  -- Combine first and last name
        SUM(ap.is_regular_savings) AS savings_count,           
        SUM(ap.is_a_fund) AS investment_count                  
    FROM adashi_staging.plans_plan ap
    LEFT JOIN adashi_staging.users_customuser ac
        ON ap.owner_id = ac.id
    GROUP BY 
        ap.owner_id, ac.first_name, ac.last_name
    HAVING 
        SUM(ap.is_regular_savings) > 0 
        AND SUM(ap.is_a_fund) > 0
),

-- Step 2: Calculate the total confirmed deposits per user from savings accounts in naira
total_deposit_table AS (
    SELECT 
        sa.owner_id, 
        SUM(sa.confirmed_amount) / 100 AS total_deposit  -- Divide by 100 to convert to naira
    FROM adashi_staging.savings_savingsaccount sa
    WHERE sa.owner_id IN (
        SELECT owner_id FROM high_value_customers
    )
    GROUP BY sa.owner_id
)

-- Step 3: Merge both tables to include customers’ total deposit information
SELECT 
    hvc.owner_id, 
    hvc.full_name AS name,  -- Final display name
    hvc.savings_count, 
    hvc.investment_count, 
    tdt.total_deposit  
FROM high_value_customers hvc
LEFT JOIN total_deposit_table tdt
    ON hvc.owner_id = tdt.owner_id
ORDER BY tdt.total_deposit DESC;  -- Sort customers by total deposit in descending order
