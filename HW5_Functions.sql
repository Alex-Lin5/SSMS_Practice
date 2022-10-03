-- 1.	Write a SELECT statement that returns two columns based on the Customers table. The first column, ContactName, is the customer’s name in this format: Customers first name (i.e. CustomerFirst column) followed by first letter of Customers last name followed by a dot. The second column, ContactPhone, is the CustPhone column without the area code. Only return rows for those customers in the area codes that start with a digit of 5. Sort the results set by Customers first name in ascending order. Use Examples database.
USE Examples
SELECT 
	CustomerFirst + '.' + LEFT(CustomerLast, 1) + '.' AS ContactName,
	RIGHT(CustPhone, 8) AS ContactPhone --(123) 1234-123
FROM Customers
WHERE SUBSTRING(CustPhone, 2, 1) = 5
ORDER BY CustomerFirst ASC

 2.	Write a SELECT statement that returns the InvoiceNumber and balance due for every invoice with a non-zero balance and an InvoiceDueDate that’s less than 15 days from today. Use AP database.
USE AP
SELECT 
	InvoiceID, 
	InvoiceTotal - CreditTotal - PaymentTotal AS Balance,
	InvoiceDueDate,
	GETDATE() AS Today
FROM Invoices
WHERE
	(InvoiceTotal - CreditTotal - PaymentTotal > 0) AND
	InvoiceDueDate - GETDATE() > 15

-- 3.	Modify the search expression for InvoiceDueDate from the solution for question 2. Rather than 15 days from today, return invoices due before the last day of the current month. Use AP database.
USE AP
SELECT 
	InvoiceID, 
	InvoiceTotal - CreditTotal - PaymentTotal AS Balance,
	InvoiceDueDate,
	EOMONTH(GETDATE()) AS DueDate
FROM Invoices
WHERE
	(InvoiceTotal - CreditTotal - PaymentTotal > 0) AND
	InvoiceDueDate < EOMONTH(GETDATE())

-- 4.	Add a column to the query described in question 2 that uses the RANK() function to return a column named BalanceRank that ranks the balance due in ascending order. Use AP database.
USE AP
SELECT 
	InvoiceID,
	RANK() OVER (ORDER BY InvoiceTotal - CreditTotal - PaymentTotal ASC) AS BalanceRank,
	InvoiceTotal - CreditTotal - PaymentTotal AS Balance,
	InvoiceDueDate,
	EOMONTH(GETDATE()) AS DueDate
FROM Invoices
WHERE
	(InvoiceTotal - CreditTotal - PaymentTotal > 0) AND
	InvoiceDueDate < EOMONTH(GETDATE())
