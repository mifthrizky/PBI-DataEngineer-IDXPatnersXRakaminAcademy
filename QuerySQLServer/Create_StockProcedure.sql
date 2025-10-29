-- == Daily Transaction
CREATE OR ALTER PROCEDURE dbo.DailyTransaction
	-- input parameter
	@start_date DATE,
	@end_date DATE
AS
BEGIN
	SET NOCOUNT ON;

	-- Main Query
	SELECT
		-- Take the date, calculate the total transactions, add up the transaction amounts
		CAST(TransactionDate AS DATE) AS Date,
		COUNT(TransactionID) AS TotalTransactions,
		SUM(Amount) AS TotalAmount
	FROM FactTransaction
	WHERE 
		CAST(TransactionDate AS DATE) BETWEEN  @start_date AND @end_date
	GROUP BY CAST(TransactionDate AS DATE)
	-- Sorted by date
	ORDER BY Date; 
END
GO

-- == BalancePerCustomer ==
CREATE OR ALTER PROCEDURE dbo.BalancePerCustomer
	-- Parameter input (nama nasabah)
	@name VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	-- Main Query
	SELECT
		-- Take the customer's name, account type, initial balance, current balance
		c.CustomerName,
		a.AccountType,
		a.Balance, -- Opening Balance
		-- Current balance
		a.Balance + ISNULL((
			SELECT SUM(CASE
							-- Add if ft.TransactionType = 'Deposit'
							WHEN ft.TransactionType = 'Deposit' THEN ft.Amount
							-- Other types are reduced
							ELSE -ft.Amount
						END)
			FROM FactTransaction ft
			WHERE ft.AccountID = a.AccountID
		), 0 ) AS CurrentBalance 

	FROM DimCustomer c
	JOIN DimAccount a ON c.CustomerID = a.CustomerID
	WHERE 
		-- Only for ‘active’ accounts
		a.Status = 'active'
		AND c.CustomerName LIKE '%' + @name + '%'
	ORDER BY c.CustomerName, a.AccountType
END
GO
