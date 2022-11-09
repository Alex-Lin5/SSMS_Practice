USE AP
GO
-- 1. Create a stored procedure named spBalanceRange that accepts three optional parameters. The procedure should return a result set consisting of VendorName, InvoiceNumber, and Balance for each invoice with a balance due, sorted with largest balance due first. The parameter @VendorVar is a mask that’s used with a LIKE operator to filter by vendor name. @BalanceMin and @BalanceMax are parameters used to specify the requested range of balances due. If called with no parameters or with a maximum value of 0, the procedure should return all invoices with a balance due. 
IF OBJECT_ID('spBalanceRange') IS NOT NULL
	DROP PROC spBalanceRange
GO
CREATE PROC spBalanceRange
	@VendorVar VARCHAR(50) = '%',
	@BalanceMin MONEY = NULL,
	@BalanceMax MONEY = NULL
AS
IF ((@BalanceMax IS NULL) AND (@BalanceMin IS NULL)) OR
	(@BalanceMax = 0)
BEGIN
	SELECT VendorName, InvoiceNumber, InvoiceTotal-CreditTotal-PaymentTotal AS Balance
	FROM Vendors V JOIN Invoices I ON
		V.VendorID = I.VendorID
	WHERE (InvoiceTotal-CreditTotal-PaymentTotal > 0) AND
		(VendorName LIKE @VendorVar)
	ORDER BY Balance DESC
END
ELSE
BEGIN
	SELECT VendorName, InvoiceNumber, InvoiceTotal-CreditTotal-PaymentTotal AS Balance
	FROM Vendors V JOIN Invoices I ON
		V.VendorID = I.VendorID
	WHERE (InvoiceTotal-CreditTotal-PaymentTotal > @BalanceMin) AND (InvoiceTotal-CreditTotal-PaymentTotal < @BalanceMax) AND
		(VendorName LIKE @VendorVar)
	ORDER BY Balance DESC
END
GO
EXEC spBalanceRange @VendorVar = '%', @BalanceMin = 0, @BalanceMax = 1000
GO

-- 2.	Code three calls to the procedure created in question 1:
--a.	passed by position with @VendorVar = ‘H%’ and no balance range
--b.	passed by name with @VendorVar omitted and a balance range from $100 to $500
--c.	passed by position with a balance due from $400 to $600, filtering for vendors whose names begin with H or M.
EXEC spBalanceRange @VendorVar = '%' -- A
GO
EXEC spBalanceRange @BalanceMin = 100, @BalanceMax = 500 -- B
GO
EXEC spBalanceRange @VendorVar = '[H, M]%', @BalanceMin = 400, @BalanceMax = 600 -- C
GO

-- 3.	Create a stored procedure named spDateRange that accepts two parameters, @DateMin and @DateMax, with data type varchar and default value null. If called with no parameters or with null values, raise an error that describes the problem. If called with non-null values, validate the parameters. Test that the literal strings are valid dates and test that @DateMin is earlier than @DateMax. If the parameters are valid, return a result set that includes the InvoiceNumber, InvoiceDate, InvoiceTotal, and Balance for each invoice for which the InvoiceDate is within the date range, sorted with latest invoice first.
IF OBJECT_ID('spDateRange') IS NOT NULL
	DROP PROC spDateRange
GO
CREATE PROC spDateRange
	@DateMin VARCHAR(30) = NULL,
	@DateMax VARCHAR(30) = NULL
AS
IF (@DateMax IS NULL) AND (@DateMin IS NULL)
	PRINT('ERROR. Did not passed parameters.')
ELSE IF NOT (ISDATE(@DateMax)=1 AND ISDATE(@DateMin)=1)
	PRINT('ERROR. Invalid input parameters for date type.')
ELSE IF (@DateMin > @DateMax)
	PRINT('ERROR. DateMin is greater than DateMax.')
ELSE
BEGIN
	SELECT InvoiceNumber, InvoiceDate, InvoiceTotal, InvoiceTotal-CreditTotal-PaymentTotal AS Balance
	FROM Invoices
	WHERE InvoiceDate > @DateMin AND InvoiceDate < @DateMax
	ORDER BY InvoiceDate DESC
END
GO

-- 4.	Code (1) A call to the stored procedure created in question 3 that returns invoices with an InvoiceDate between October 1 and December 31, 2015, (2) A call to the stored procedure again that returns invoices with an @DateMin is December 10. These calls should also catch any errors that are raised by the procedure and print the error number and description.
SELECT
	MAX(InvoiceDate) AS MaxInvoiceDate,
	MIN(InvoiceDate) AS MinInvoiceDate
FROM Invoices
GO
EXEC spDateRange @DateMin = '2015-10-01', @DateMax = '2015-12-31' -- (1)
GO
EXEC spDateRange @DateMin = '2015-12-10' -- (2)
GO

-- 5.	Create a scalar-valued function named fnPaidInvoiceID that returns the InvoiceID of the latest invoice with an paid balance. Test the function in the following SELECT statement:
IF OBJECT_ID('fnPaidInvoiceID') IS NOT NULL
	DROP FUNCTION fnPaidInvoiceID
GO
CREATE FUNCTION fnPaidInvoiceID()
	RETURNS INT
BEGIN
	RETURN (
		SELECT TOP 1 InvoiceID
		FROM Invoices
		WHERE InvoiceTotal-CreditTotal-PaymentTotal = 0
		ORDER BY InvoiceDate DESC
	)
END
GO
SELECT VendorName, InvoiceNumber, InvoiceDueDate, InvoiceTotal - CreditTotal - PaymentTotal AS Balance
FROM Vendors JOIN Invoices
ON Vendors.VendorID = Invoices.VendorID
WHERE InvoiceID = dbo.fnPaidInvoiceID();
GO

-- 6.	Create a table-valued function named fnDateRange, similar to the stored procedure of question 3. The function requires two parameters of data type smalldatetime. Don’t validate the parameters. Return a result set that includes the InvoiceNumber, InvoiceDate, InvoiceTotal, and Balance for each invoice for which the InvoiceDate is within the date range. Invoke the function from within a SELECT statement to return those invoices with InvoiceDate between January 1 and March 31, 2016.
IF OBJECT_ID('fnDateRange') IS NOT NULL
	DROP FUNCTION fnDateRange
GO
CREATE FUNCTION fnDateRange(
	@DateMin SMALLDATETIME = NULL,
	@DateMax SMALLDATETIME = NULL
)
	RETURNS TABLE
RETURN (
	SELECT InvoiceNumber, InvoiceDate, InvoiceTotal, InvoiceTotal-CreditTotal-PaymentTotal AS Balance
	FROM Invoices
	WHERE InvoiceDate > @DateMin AND InvoiceDate < @DateMax
)
GO
SELECT *
FROM Invoices Whole JOIN 
	fnDateRange('2016-01-01', '2016-03-31') Part ON
	Whole.InvoiceNumber = Part.InvoiceNumber
ORDER BY Whole.InvoiceDate DESC
GO
SELECT *
FROM Invoices Whole JOIN 
	fnDateRange('2021-01-01', '2021-12-31') Part ON
	Whole.InvoiceNumber = Part.InvoiceNumber
ORDER BY Whole.InvoiceDate DESC
GO

-- 7.	Use the function you created in question 6 in a SELECT statement that returns five columns: VendorCity and the four columns returned by the function.
SELECT VendorCity, I.InvoiceNumber, I.InvoiceDate, I.InvoiceTotal, I.InvoiceTotal-I.CreditTotal-I.PaymentTotal AS Balance
FROM Invoices I JOIN 
	fnDateRange('2021-01-01', '2021-12-31') Part ON
	I.InvoiceNumber = Part.InvoiceNumber
	JOIN Vendors V ON
	I.VendorID = V.VendorID
ORDER BY I.InvoiceDate DESC
GO
