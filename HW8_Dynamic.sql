-- 1.	Write a view named VendorsInvoices that returns four columns: VendorName, InvoiceNumber, InvoiceDate and InvoiceTotal. Then, write a SELECT statement that returns all the columns in the view, sorted by InvoiceTotal in descending order, where the first letter of the vendor name is Q, or R.
USE AP
GO
CREATE VIEW VendorsInvoices AS
	SELECT VendorName, InvoiceNumber, InvoiceDate, InvoiceTotal
	FROM Invoices, Vendors
GO
SELECT *
FROM VendorsInvoices
WHERE (LEFT(VendorName, 1) = 'Q') OR (LEFT(VendorName, 1) = 'R')
ORDER BY InvoiceTotal DESC
GO

-- 2.	Create a view named Top10PaidInvoices that returns three columns for each vendor: VendorName, FirstInvoiceDate (the least recent invoice date), and SumOfInvoices (the sum of the InvoiceTotal column). Return only the 10 vendors with the smallest SumOfInvoices and include only paid invoices (i.e. InvoiceTotal - CreditTotal - PaymentTotal = 0). Then write a SELECT statement to show results of the view.
USE AP
GO
IF OBJECT_ID('Top10PaidInvoices') IS NOT NULL
	DROP VIEW Top10PaidInvoices
GO
CREATE VIEW Top10PaidInvoices AS
	SELECT TOP 10 
		VendorName, 
		MAX(InvoiceDate) AS FirstInvoiceDate,
		SUM(InvoiceTotal) AS SumOfInvoices
	FROM Invoices, Vendors
	WHERE InvoiceTotal - CreditTotal - PaymentTotal >= 0
	GROUP BY VendorName
	ORDER BY SumOfInvoices DESC
GO
SELECT *
FROM Top10PaidInvoices
ORDER BY SumOfInvoices DESC
GO

-- 3.	Create an updatable view named VendorAddress that returns the VendorID and AddressInfo (i.e. VendorAddress1 + ‘, ’ + VendorAddress2 + ‘, ’ + VendorCity + ‘, ’ + VendorState + ‘, ’ + VendorZipCode + ‘.’) for each vendor. Whenever VendorAddress2 is NULL, substitute the NULL with a blank space. Then write a SELECT query to examine the result set where VendorID = 5. Write a SELECT statement to verify the result.
USE AP
GO
IF OBJECT_ID('VendorAddress') IS NOT NULL
	DROP VIEW VendorAddress
GO
CREATE VIEW VendorAddress AS
	SELECT 
		VendorID,
		VendorAddress1 + ', ' + ISNULL(VendorAddress2, ' ') + ', ' + VendorCity + ', ' + VendorState + ', ' + VendorZipCode + '.' AS AddressInfo
		
	FROM Vendors
GO
SELECT *
FROM VendorAddress
WHERE VendorID = 5
GO

-- 4.	Write a SELECT statement that selects all the columns for the catalog view that returns information about foreign keys in the Examples database. How many foreign key(s) is/are defined in the Examples database and what is/are they?
USE Examples
GO
SELECT *
FROM sys.foreign_keys

-- 5.	Write a script that declares and sets a variable named @TotalBalanceDue, which is equal to the total outstanding balance due. What is the datatype of the variable @TotalBalanceDue? If that balance due is less than $50,000.00, the script should return a result set consisting of VendorName, InvoiceNumber, InvoiceDueDate, and Balance for each invoice with a balance due, sorted with the newest due date first. Then also return the value of @TotalBalanceDue in the format of “Balance due is ...”. If the total outstanding balance due is more than $50,000.00, the script should return the message “Balance due is more than $50,000.00”. 
USE AP
DECLARE @TotalBalanceDue MONEY;
SET @TotalBalanceDue = (
	SELECT SUM(InvoiceTotal)
	FROM Invoices
)
IF @TotalBalanceDue <= 50000
BEGIN
	SELECT VendorName, InvoiceNumber, InvoiceDueDate,
		InvoiceTotal - CreditTotal - PaymentTotal AS Balance
	FROM Vendors V JOIN Invoices I ON
		V.VendorID = I.VendorID
	ORDER BY InvoiceDueDate DESC
	PRINT 'Balance Due is $' + CONVERT(VARCHAR, @ToTalBalanceDue, 1)
END
ELSE
BEGIN
	--PRINT 'Balance Due is $' + CONVERT(VARCHAR, @ToTalBalanceDue, 1)
	PRINT 'Balance due is more than $50,000.00'
END
GO

-- 6.	Explain the execution result generated by the following script. Then Write a script that generates the same result set but uses a temporary table in place of the derived table. Make sure your script tests for the existence of any objects it creates.
   --USE AP;
   --SELECT VendorName,LastInvoiceDate, InvoiceTotal
   --FROM Invoices
   --JOIN (SELECT VendorID, MAX(InvoiceDate) AS LastInvoiceDate
   --            FROM Invoices
   --            GROUP BY VendorID) AS LastInvoice
   --ON (Invoices.VendorID = LastInvoice.VendorID AND
   --    Invoices.InvoiceDate = LastInvoice.LastInvoiceDate)
   --JOIN Vendors ON Invoices.VendorID = Vendors.VendorID
   --ORDER BY VendorName, LastInvoiceDate;
USE AP
SELECT VendorID, MAX(InvoiceDate) AS LastInvoiceDate
INTO #LastInvoice
FROM Invoices
GROUP BY VendorID
SELECT VendorName,LastInvoiceDate, InvoiceTotal
FROM Invoices JOIN #LastInvoice ON 
	(Invoices.VendorID = #LastInvoice.VendorID AND
   Invoices.InvoiceDate = #LastInvoice.LastInvoiceDate)
JOIN Vendors ON 
	Invoices.VendorID = Vendors.VendorID
ORDER BY VendorName, LastInvoiceDate;
GO

-- 7.	Write a script that generates the date and invoice total of the latest invoice issued by each vendor, using a view instead of a derived table. Also write the script that creates the view, then use SELECT statement to show result of the view. Make sure that your script tests for the existence of the view. The view doesn’t need to be redefined each time the script is executed.
USE AP
GO
CREATE VIEW LatestInvoices AS
	SELECT VendorID, MAX(InvoiceDate) AS LatestInvoice
	FROM Invoices
	GROUP BY VendorID
GO
SELECT I.VendorID, VendorName, InvoiceDate, InvoiceTotal
FROM Invoices I JOIN LatestInvoices L ON
	I.InvoiceDate = L.LatestInvoice AND I.VendorID = L.VendorID
	JOIN Vendors V ON
	I.VendorID = V.VendorID
ORDER BY VendorID ASC
GO
SELECT *
FROM LatestInvoices
GO

-- 8.	 Write a script that uses dynamic SQL to return a single column that represents the number of rows in the first table in the current database. The script should automatically choose the table that appears first alphabetically, and it should exclude tables named dtproperties and sysdiagrams. Name the column CountOfTable, where Table is the chosen table name. Show results for AP database.
USE AP
GO
DROP TABLE IF EXISTS #FirstTable
CREATE TABLE #FirstTable(
	TableName VARCHAR(50),
	RowCounts INT
)
DECLARE @TableName VARCHAR(50)
DECLARE @CountOfTable INT
DECLARE @ExecVar VARCHAR(1000)
SET @TableName = (
	SELECT TOP 1 sys.tables.name AS UserTable
	FROM sys.tables
	WHERE (sys.tables.name NOT IN ('dtproperties', 'sysdiagrams'))
	ORDER BY sys.tables.name ASC
)
SET @ExecVar = ''
SET @ExecVar = @ExecVar + 'DECLARE @TheCount INT;'
SET @ExecVar = @ExecVar + 'SET @TheCount = (SELECT COUNT(*)  FROM '
SET @ExecVar = @ExecVar + @TableName + ');'
SET @ExecVar = @ExecVar + 'INSERT INTO #FirstTable '
SET @ExecVar = @ExecVar + 'VALUES ('' ' + @TableName
SET @ExecVar = @ExecVar + ' '', @TheCount)'
EXEC (@ExecVar)
SET @CountOfTable = (SELECT RowCounts FROM #FirstTable)
PRINT 'Table ' + @TableName + ' Has ' + CONVERT(VARCHAR, @CountOfTable) + ' Rows.'
SELECT *
FROM #FirstTable
GO