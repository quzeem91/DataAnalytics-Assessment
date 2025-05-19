USE adashi_staging;

-- Step 1: Count the number of successful transactions per customer per month
WITH monthly_transaction_counts AS (
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
        COUNT(*) AS monthly_transaction_count
    FROM savings_savingsaccount
    WHERE -- retaining entries with succesful transactions
        LOWER(transaction_status) IN (
            'success', 'successful', 'monnify_success',
            'support credit', 'supportcredit', 'earnings'
        )
    GROUP BY owner_id, DATE_FORMAT(transaction_date, '%Y-%m')
),

-- Step 2: Compute the average monthly transaction count per customer
average_transaction_per_customer AS (
    SELECT 
        owner_id,
        AVG(monthly_transaction_count) AS avg_transaction_per_month
    FROM monthly_transaction_counts
    GROUP BY owner_id
),

-- Step 3: Classify customers into frequency buckets based on their average monthly transactions
customer_frequency_categories AS (
    SELECT 
        owner_id,
        avg_transaction_per_month,
        CASE 
            WHEN avg_transaction_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transaction_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM average_transaction_per_customer
)

-- Step 4: Aggregate and summarize frequency category counts
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transaction_per_month), 1) AS avg_transactions_per_month
FROM customer_frequency_categories
GROUP BY frequency_category
ORDER BY customer_count DESC;
