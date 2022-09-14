---- 1.	Write a SELECT statement that returns three columns from the Employees table: LastName, FirstName, and DeptNo. Use Examples database.
--SELECT LastName, FirstName, DeptNo
--FROM Examples.dbo.Employees

---- 2.	Write a SELECT statement that returns two columns from the Employees table, named ‘Name’, and ‘DeptNumber’:
--       --And filter for Employees with DeptNo value as 4. Use Examples database.
--SELECT LastName + ' ' + FirstName AS Name, DeptNo AS DeptNumber
--FROM Examples.dbo.Employees
--WHERE DeptNo = 4

---- 3.	Write a SELECT statement that returns one column from the Customers table named “Full Name”. Create this column from the CustomerFirst and CustomerLast columns. Format it as follows: CustomerLast, comma, space, CustomerFirst. Sort the result set by CustomerLast from “A-Z”. Use Examples database.
--SELECT CustomerLast + ', ' + CustomerFirst AS 'Full Name'
--FROM Examples.dbo.Customers
--ORDER BY CustomerLast ASC

---- 4.	Write a SELECT statement that determines whether the PaymentDate column of the Invoices table has any valid values. To be valid, PaymentDate must be a non-null value if there is no balance due, and a null value if there is balance due. Code a compound condition in the WHERE clause that tests for these conditions. (Balance: InvoiceTotal minus the sum of PaymentTotal and CreditTotal). Use AP database.
--WITH Validation as (
--SELECT PaymentDate, InvoiceTotal - (PaymentTotal + CreditTotal) AS Balance
--FROM AP.dbo.Invoices)
--SELECT * FROM Validation
--WHERE (PaymentDate IS NOT NULL AND Balance <= 0) 
--OR (PaymentDate IS NULL AND Balance > 0)


---- 5.	Write a SELECT statement that returns five columns: CustLastName, CustCity, CustState, OrderDate and ShippedDate from the Customers table and Orders table. The result set should have one row for each customer, with the city, order date and shipped date for that customer’s ID. Filter for Customers whose CustState is ‘MA’ and ShippedDate is null. Sort the result set by CustLastName from A to Z. Use ProductOrders database.
--USE [ProductOrders]
--GO
--SELECT CustLastName, CustCity, CustState, OrderDate, ShippedDate
--FROM [Customers] JOIN [Orders] 
--	ON CustState = 'MA' AND ShippedDate IS NULL
--ORDER BY CustLastName ASC

---- 6.	Write a SELECT statement that returns two columns: VendorName and FullName (A concatenation of VendorContactLName and VendorContactFName, with a space in between). The result set should have one row for each vendor whose contact has the same first name (i.e. VendorContactFName) as another vendor's contact. Sort the final result set by FullName column from Z to A. Use AP database.
--USE [AP]
--GO
--SELECT T1.VendorName, T1.VendorContactLName + ' ' + T1.VendorContactFName AS FullName
--FROM [Vendors] T1
--	INNER JOIN [Vendors] T2 
--	ON (T1.VendorContactFName = T2.VendorContactFName)
--		AND T1.VendorName <> T2.VendorName
--ORDER BY FullName DESC

---- 7.	Use the UNION operator to generate a result set consisting of two columns from the Customers table: CustomerFirst and CustState. If the customer is in Illinois, the CustState value should be “IL”; otherwise, the CustState value should be “Not in IL”. Sort the final result set by CustomerFirst from Z-A. Use Examples database.
--USE [Examples]
--GO
--SELECT CustomerFirst, 'IL' AS CustState
--FROM [Customers]
--WHERE CustState = 'IL'
--UNION
--SELECT CustomerFirst, 'Not in IL' AS CustState
--FROM [Customers]
--WHERE CustState <> 'IL'
--ORDER BY CustomerFirst DESC

---- 8.	Write a SELECT statement that returns two columns from the GLAccounts table: AccountNo and AccountDescription. The result set should have one row for each account number that has never been used (i.e. AccountNo in InvoiceLineItems table has null value). Sort the final result set by AccountNo in descending order. Use AP database. (HINT: Join GLAccounts table and InvoiceLineItems table.)
--USE [AP]
--GO
--SELECT GLAccounts.AccountNo, GLAccounts.AccountDescription
--FROM [GLAccounts] LEFT JOIN [InvoiceLineItems]
--	ON InvoiceLineItems.AccountNo = GLAccounts.AccountNo
--WHERE InvoiceLineItems.AccountNo IS NULL
--ORDER BY AccountNo DESC