-- 1.	Write a set of action queries coded as a transaction to reflect the following change: “The Drawing Board” has been purchased by “Computer Library” and the new company is named ‘ComputerBoard’. Rename one of the vendors and delete the other after updating the VendorID column in the Invoices table. Use SELECT statement to verify the results.
USE AP_COPY
GO
BEGIN TRANSACTION
	DELETE Invoices
	WHERE VendorID = 68
	INSERT INTO Invoices
	(VendorID, InvoiceNumber, InvoiceDate, InvoiceTotal, TermsID, InvoiceDueDate) VALUES
	(68, 'K100001', GETDATE(), 100, 3, GETDATE()+30) -- VendorName = Computer Library

	DECLARE @newInvoiceID INT
	SET @newInvoiceID = (
		SELECT InvoiceID
		FROM Invoices
		WHERE VendorID = 68
	)

	INSERT INTO InvoiceLineItems
	(InvoiceID, InvoiceLineItemDescription, InvoiceSequence, AccountNo, InvoiceLineItemAmount) VALUES
	(@newInvoiceID, 'The Drawing Board', 10, 160, 100)
	UPDATE Vendors
	SET VendorName = 'ComputerBoard'
	WHERE VendorName = 'Computer Library'
COMMIT
GO

SELECT I.InvoiceID, V.VendorID, VendorName, InvoiceLineItemDescription, G.AccountNo, AccountDescription, TermsID
FROM Invoices I 
	JOIN Vendors V ON I.VendorID = V.VendorID
	JOIN InvoiceLineItems IL ON IL.InvoiceID = I.InvoiceID
	JOIN GLAccounts G ON G.AccountNo = IL.AccountNo
WHERE VendorName LIKE 'COM%'
GO

-- 2.	Write a set of action queries coded as a transaction to move rows from the Invoices table to the InvoiceArchive table. Insert all paid invoices from Invoices into InvoiceArchive, but only if the invoice doesn’t already exist in the InvoiceArchive table. Then, delete all paid invoices from the Invoices table, but only if the invoice exists in the InvoiceArchive table. Use SELECT statement to verify the results.
USE AP_COPY
GO
BEGIN TRAN
	INSERT InvoiceArchive 
	SELECT *
	FROM Invoices 
	WHERE InvoiceTotal-CreditTotal-PaymentTotal = 0 AND
		InvoiceID NOT IN (
			SELECT InvoiceID
			FROM InvoiceArchive
			WHERE InvoiceTotal-CreditTotal-PaymentTotal = 0 
		)
	DELETE Invoices
	WHERE InvoiceID IN (
			SELECT InvoiceID
			FROM InvoiceArchive
			WHERE InvoiceTotal-CreditTotal-PaymentTotal = 0 
		) 
COMMIT
GO
SELECT InvoiceTotal-CreditTotal-PaymentTotal AS Balance, *
FROM Invoices;
SELECT InvoiceTotal-CreditTotal-PaymentTotal AS Balance, *
FROM InvoiceArchive;
GO