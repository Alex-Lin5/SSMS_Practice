-- 1.	Write a SELECT statement that returns two columns: VendorName and their individual PaymentAverage, where PaymentAverage is the average of the PaymentTotal column. Return 5 vendors who’ve been paid the most. Use AP database.
USE AP
GO
SELECT TOP 5
	Vendors.VendorName,
	AVG(Invoices.PaymentTotal) AS PaymentAverage
FROM Invoices JOIN Vendors
	ON Invoices.VendorID = Vendors.VendorID
GROUP BY Invoices.VendorID, Vendors.VendorName
ORDER BY PaymentAverage DESC

-- 2.	Write a SELECT statement that returns: AccountDescription, LineItemCount, and LineItemSum. LineItemCount is the number of entries in the InvoiceLineItems table that have that AccountNo. LineItemSum is the sum of the InvoiceLineItemAmount column for that AccountNo. Group the result set by account description, and sort it in ascending order of LineItemSum. Use AP database.
USE AP
SELECT 
	GLAccounts.AccountDescription,
	COUNT(*) AS LineItemCount,
	SUM(InvoiceLineItems.InvoiceLineItemAmount) AS LineItemSum
FROM InvoiceLineItems JOIN GLAccounts
	ON GLAccounts.AccountNo = InvoiceLineItems.AccountNo
GROUP BY AccountDescription
ORDER BY LineItemSum ASC

-- 3.	Write a SELECT statement that returns three columns: VendorName, InvoiceCount andInvoiceAverage. InvoiceCount is the count of the number of invoices, and InvoiceAverage is theaverage of the InvoiceTotal of each vendor. Filter the result set to include only those rows with InvoiceCount more than 2. Group the result set by VendorName and sort the result set in descending order of InvoicesCount. Use AP database.
USE AP
SELECT
	Vendors.VendorName,
	COUNT(*) AS InvoiceCount,
	AVG(Invoices.InvoiceTotal) AS InvoiceAverage
FROM Vendors JOIN Invoices 
	ON Invoices.VendorID = Vendors.VendorID
GROUP BY VendorName
ORDER BY InvoiceAverage DESC

 -- 4.	Write a SELECT statement that answers the following question: What is the sum of sales for each “Sale Year”? Use the WITH ROLLUP operator to include a row that gives the grand sum. Use SalesTotals table from Examples database.
 USE Examples
 SELECT 
	SalesYear,
	SUM(SalesTotal) AS Sales
 FROM SalesTotals
 GROUP BY ROLLUP (SalesYear);

-- 5.	Write a SELECT statement that return the vendor name and the total number of accounts that apply to that vendor’s invoices. Filter the result set to include only the vendor who is being paid more than once. Sort the result set in ascending order of VendorName. (HINT: Use Vendors table, Invoices table and InvoiceLineItems table of AP database).
USE AP
SELECT 
	Vendors.VendorName,
	COUNT(*) AS InvoicesNo
FROM InvoiceLineItems 
	JOIN Invoices ON
	Invoices.InvoiceID = InvoiceLineItems.InvoiceID 
	JOIN Vendors ON
	Vendors.VendorID = Invoices.VendorID
GROUP BY Vendors.VendorName, Invoices.VendorID
HAVING COUNT(*) > 1
ORDER BY VendorName ASC

-- 6.	Write a SELECT statement that returns the distinct VendorName (i.e. VendorName should not be repeated in the result). Filter the result set to include only those vendors with invoices having a PaymentTotal that is greater than the average PaymentTotal for all invoices. Sort the result set in ascending order of VendorName. Use AP database.
USE AP
SELECT 
	Vendors.VendorID,
	VendorName,
	MAX(Invoices.PaymentTotal) AS MaxPayment,
	(SELECT AVG(PaymentTotal) FROM Invoices) AS AvgPayment
FROM Vendors JOIN Invoices ON
	Vendors.VendorID = Invoices.VendorID
GROUP BY Vendors.VendorID, VendorName
HAVING
	MAX(Invoices.PaymentTotal) >
	(SELECT AVG(PaymentTotal) FROM Invoices)
ORDER BY VendorName ASC

-- 7.	Write a SELECT statement that returns the sum of the largest unpaid invoices submitted by each vendor. Use a derived table that returns MAX(InvoiceTotal) grouped by VendorID, filtering for invoices with a balance due. (HINT: Balance = InvoiceTotal – CreditTotal - PaymentTotal). Use AP database.
USE AP
SELECT 
	Invoices.VendorID,
	VendorName,
	MAX(InvoiceTotal) AS MaxInvoice,
	InvoiceTotal - CreditTotal - PaymentTotal AS Balance
FROM Invoices JOIN Vendors ON
	Invoices.VendorID = Vendors.VendorID
WHERE Invoices.VendorID IN 
	(SELECT VendorID
	FROM Invoices
	WHERE InvoiceTotal - CreditTotal - PaymentTotal > 0)
GROUP BY Invoices.VendorID, VendorName, InvoiceTotal - CreditTotal - PaymentTotal

-- 8.	Write a SELECT statement that returns the id, city, state, and zip-code of each vendor that’s located in a unique state with a unique city (combination is unique). In other words, don’t include vendors that have a both state and city in common with another vendor. Sort the result set by state in descending order. Use AP database.
USE AP
SELECT VendorID, VendorName, VendorCity, Vendors.VendorState, VendorZipCode
FROM Vendors JOIN 
	(SELECT
		VendorState,
		COUNT(*) AS StateNo
	FROM Vendors
	GROUP BY VendorState
	HAVING COUNT(*) = 1)
	AS Part
	ON Vendors.VendorState = Part.VendorState
ORDER BY VendorState DESC
	