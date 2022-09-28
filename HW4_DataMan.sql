USE AP
DELETE InvoiceCopy
DELETE VendorCopy
DROP TABLE InvoiceCopy
DROP TABLE VendorCopy

-- 1.	Create VendorCopy table and InvoiceCopy table.
USE AP
SELECT *
INTO VendorCopy
FROM Vendors

SELECT *
INTO InvoiceCopy
FROM Invoices

-- 2.	Write an INSERT statement that adds a row to the InvoiceCopy table with the following values (USE SELECT statement to verify data changes in the table before and after the modification):
--VendorID:	4	InvoiceTotal:	$750.48
--TermsID:	2	InvoiceNumber:	UN-004-400
--PaymentTotal:	$100.00	InvoiceDueDate:	12/01/22
--InvoiceDate:	10/01/22	CreditTotal:	$7.50
--Do we explicitly need to have an InvoiceID to insert?
USE AP
INSERT INTO InvoiceCopy
	(VendorID, InvoiceTotal, TermsID, InvoiceNumber, 
	PaymentTotal, InvoiceDueDate, InvoiceDate, CreditTotal)
VALUES
	(4, 750.48, 2, 'UN-004-400', 100, '12/01/22', '10/01/22', 7.5)

-- 3.	Write an UPDATE statement that modifies the VendorCopy table. Change the default account number to 970 for each vendor that has a default account number of 170. (USE SELECT statement to verify data changes in the table before and after the modification).
USE AP
UPDATE VendorCopy
SET DefaultAccountNo = 970
WHERE DefaultAccountNo = 170
USE AP
SELECT DefaultAccountNo, VendorName, VendorID
FROM VendorCopy
ORDER BY DefaultAccountNo ASC

-- 4.	Write an UPDATE statement that modifies the InvoiceCopy table. Change the TermsID to 3 for each invoice that’s from a vendor with a defaultTermsID of 2. Use a subquery. (USE SELECT statement to verify data changes in the table before and after the modification).
USE AP
UPDATE InvoiceCopy
SET TermsID = 3
FROM VendorCopy V JOIN InvoiceCopy I ON
	V.VendorID = I.VendorID
WHERE V.DefaultTermsID = 2
USE AP
SELECT I.VendorID, VendorName, InvoiceID, I.TermsID, V.DefaultTermsID
FROM InvoiceCopy I JOIN VendorCopy V ON
	V.VendorID = I.VendorID
ORDER BY I.TermsID, V.DefaultTermsID ASC

-- 5.	Write a DELETE statement that deletes all vendors in the state of Illinois from the VendorCopy table. (USE SELECT statement to verify data changes in the table before and after the modification).
USE AP
DELETE VendorCopy
WHERE VendorState = 'IL'
USE AP
SELECT VendorID, VendorName, VendorState
FROM VendorCopy
ORDER BY VendorState

6.	Write a DELETE statement for the VendorCopy table. Delete the vendors that are located in states from which no vendor has ever sent an invoice. (USE SELECT statement to verify data changes in the table before and after the modification).
USE AP
DELETE VendorCopy
WHERE VendorID NOT IN(
	SELECT V.VendorID
	FROM VendorCopy V RIGHT JOIN InvoiceCopy I ON
		V.VendorID = I.VendorID
)
USE AP
SELECT DISTINCT I.InvoiceID, V.VendorID, VendorName
FROM VendorCopy V JOIN InvoiceCopy I ON
	V.VendorID = I.VendorID
ORDER BY V.VendorID ASC

-- 7.	Write a SELECT statement that returns four columns based on the PaymentTotal column of the Invoices table:
--•	Use CAST function to return the first column as data type decimal with 2 digits to the right of the decimal point.
--•	Use CAST to return the second column as a VARCHAR.
--•	Use CONVERT function to return third column as the same type as the first column.
--•	Use CONVERT to return the fourth column as a VARCHAR, using style 5.
USE AP
SELECT
	CAST(PaymentTotal AS decimal(10,2)) AS CastDec,
	CAST(PaymentTotal AS VARCHAR) AS CastVar,
	CONVERT(decimal(10,2), PaymentTotal) AS ConvDec,
	CONVERT(varchar, PaymentTotal, 5) AS ConvVar
FROM Invoices

-- 8.	Write a SELECT statement that returns four columns based on the PaymentDate column of the Invoices table:
--•	Use the CAST function to return the first column as data type VARCHAR.
--•	Use the CONVERT function to return the second and third columns as a VARCHAR, using style 1 and style 9, respectively.
--•	Use the CAST function to return the fourth column as a data type real.
USE AP
SELECT
	CAST(PaymentDate AS VARCHAR),
	CONVERT(VARCHAR, PaymentDate, 1),
	CONVERT(VARCHAR, PaymentDate, 9),
	CAST(PaymentDate AS REAL)
FROM Invoices