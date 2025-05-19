USE adashi_staging;

-- Step 1: Calculate transaction summary per customer
WITH transaction_summary AS (
    SELECT 
        owner_id,
        COUNT(*) AS total_transactions,
        AVG(0.001 * (confirmed_amount / 100)) AS avg_profit_per_transaction -- convert kobo to naira
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0 AND LOWER(transaction_status) IN (
            'success', 'successful', 'monnify_success',
            'support credit', 'supportcredit', 'earnings'
        )
    GROUP BY owner_id
),

-- Step 2: Get account tenure in months from signup
account_tenure AS (
    SELECT 
        id AS customer_id,
        CONCAT(first_name, ' ', last_name) AS name,
        TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE) AS tenure_months
    FROM users_customuser
)

-- Step 3: Combine both and calculate CLV
SELECT 
    at.customer_id,
    at.name,
    at.tenure_months,
    ts.total_transactions,
    ROUND(
        (ts.total_transactions / NULLIF(at.tenure_months, 0)) * 12 * ts.avg_profit_per_transaction, 
        2
    ) AS estimated_clv
FROM account_tenure at
JOIN transaction_summary ts ON at.customer_id = ts.owner_id
ORDER BY estimated_clv DESC;
