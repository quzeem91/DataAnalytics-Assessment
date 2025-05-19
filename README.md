# DataAnalytics-Assessment

## Task 1: High-Value Customers with Multiple Products 
### ✅**Approach:**

To help the business identify **high-value customers** for cross-selling opportunities, specifically those with both a **savings** and an **investment (fund) plan**, I followed a multi-step SQL approach:

1.  **Customer Segmentation:**
    
    *   I created a Common Table Expression (CTE) named high\_value\_customers from the plans\_plan table.
        
    *   The CTE filters customers with at least one regular savings plan (is\_regular\_savings = 1) and one investment plan (is\_a\_fund = 1) using aggregation and the HAVING clause.
        
    *   Customer names were included via a LEFT JOIN with the users\_customuser table to display readable identifiers (e.g., John Doe) while preserving all qualified customer IDs.
        
2.  **Deposit Aggregation:**
    
    *   A second CTE, total\_deposit\_table, was created to calculate total deposits per customer using the confirmed\_amount field from the savings\_savingsaccount table.
        
    *   Only customers from the first CTE were considered here using a subquery filter to ensure alignment.
        
3.  **Final Output Construction:**
    
    *   In the final SELECT, I merged both CTEs to retrieve each customer's:
        
        *   owner\_id
            
        *   Full name
            
        *   Number of savings and investment plans
            
        *   Total deposit amount (converted to naira by dividing by 100)
            
    *   The result was ordered by total deposits in descending order to surface the most valuable customers first.
        

### ⚠️ **Challenges:**

One of the key issues encountered was **duplicate customer names** appearing in the final result. Although owner\_id values remained unique, the repetition of names raised concerns about potential data quality issues or customers with multiple accounts.

To validate the uniqueness of the data:

*   I modified the query to include email addresses alongside owner\_id from the users\_customuser table.
    
*   This helped confirm that the repeated names were not duplicates but rather different customers with identical names or customers with multiple accounts.

## Task 2: Transaction Frequency Analysis 
### ✅ **Approach**

To help the finance team segment customers based on how frequently they transact, I created a multi-step query using Common Table Expressions (CTEs):

1.  **Monthly Transaction Counts (monthly\_transaction\_counts)**:For each customer, I calculated the number of transactions per month by grouping transaction records (from savings\_savingsaccount) by owner\_id and transaction month. Only transactions with statuses that typically indicate success or credit inflow were considered valid for this analysis.
    
2.  **Average Transactions Per Month (average\_transaction\_per\_customer)**:I then computed the average number of transactions per month for each customer using the results of the previous CTE.
    
3.  **Customer Segmentation (customer\_frequency\_categories)**:Based on the average monthly transactions, customers were categorized into:
    
    *   **High Frequency** (≥10 transactions/month)
        
    *   **Medium Frequency** (3–9 transactions/month)
        
    *   **Low Frequency** (≤2 transactions/month)
        
4.  **Final Output**:The final query aggregates the result by frequency category, returning the total number of customers in each category and the average monthly transactions within that segment—aligned with the expected output.
    

### ⚠️ **Challenges**

A key challenge was defining what constitutes a "valid" transaction for frequency analysis.The problem statement did not provide specific criteria, so I assumed only transactions with positive or successful statuses were relevant.To ensure consistency, I filtered the transaction\_status to include only:

*   'success', 'successful', 'monnify\_success'
    
*   'support credit', 'supportcredit', 'earnings'
    

These statuses likely represent completed or valid credits that reflect real user activity. However, this assumption may need adjustment based on domain-specific transaction logic or additional context from the finance team.

## Task 3: Account Inactivity Alert 
### ✅ **Approach**

To identify inactive accounts (either Savings or Investment) with no inflow transactions in the past 365 days:

1.  **Isolate Inactive Customers**: A Common Table Expression (inactive\_customers) was created to calculate the number of days since each customer's most recent inflow (confirmed\_amount > 0). Only those with over 365 days of inactivity were selected.
    
2.  **Retrieve Last Active Plan**: The savings\_savingsaccount table was joined back using both owner\_id and last\_transaction\_date to accurately retrieve the plan\_id associated with the customer's last inflow.
    
3.  **Classify Plan Type**: The plans\_plan table was joined to determine whether the associated plan is a **Savings** (is\_regular\_savings = 1) or **Investment** (is\_a\_fund = 1), which was used to assign the account type.
    
4.  **Final Output**: The final SELECT produced a single row per inactive customer, including: plan\_id, owner\_id, type, last\_transaction\_date, and inactive\_days, matching the expected output.
    

### ⚠️ **Challenges**

The main challenge was accurately determining the **type of account** (Savings or Investment) without duplicating rows across multiple plans per customer. This was resolved by:

*   First, identifying the **last inflow date** per customer, then
    
*   Joining **only that transaction** to get the correct plan\_id, and finally
    
*   Using flags from the plans\_plan table to determine the account type.

## Task 4: Customer Lifetime Value (CLV) Estimation 
### ✅ **Approach**

To estimate Customer Lifetime Value (CLV), I followed the simplified formula provided in the task:

I broke the query into three key steps:

1.  **Transaction Summary per Customer**I queried the savings\_savingsaccount table to:
    
    *   Count the number of valid inflow transactions per customer (total\_transactions)
        
    *   Calculate the average profit per transaction, assuming profit is 0.1% of each transaction value. Since the confirmed\_amount is stored in **kobo**, I converted it to **naira** by dividing by 100.
        
2.  **Account Tenure Calculation** Using the users\_customuser table, I calculated account tenure in months by comparing each customer's date\_joined to the current date.
    
3.  **CLV Computation and Output** I applied the provided CLV formula using the values computed in the earlier steps and returned the results ordered by estimated CLV in descending order.
    

### ⚠️ **Challenges**

Just like in the transaction frequency task, what qualifies as a "transaction" wasn’t clearly defined. To ensure consistency, I only considered records with transaction\_status values like:

*   'success', 'successful', 'monnify\_success'
    
*   'support credit', 'supportcredit', 'earnings'
    

These statuses were interpreted as successful or valid inflow transactions. If the business defines transactions differently, the logic may need to be adjusted.
