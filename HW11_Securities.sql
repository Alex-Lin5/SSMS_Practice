-- 1.	Write a script that creates a user-defined database role named PaymentEntry in the AP database. Give UPDATE permission to the new role for the Vendors and Invoices table, UPDATE and INSERT permission for the InvoiceLineItems table, and SELECT permission for all user tables.
USE AP
GO
CREATE ROLE PaymentEntry
GRANT UPDATE
ON Vendors TO PaymentEntry
GRANT UPDATE
ON Invoices TO PaymentEntry
GRANT UPDATE, INSERT
ON InvoiceLineItems TO PaymentEntry

-- 2.	Write a script that (1) creates a login ID named “Fall2022” with the password “12345678”; (2) sets the default database for the login to the AP database; (3) creates a user named “James” for the login; and (4) assigns the user to the PaymentEntry role you created in question 1.
CREATE LOGIN Fall2022 WITH PASSWORD = '12345678',
	DEFAULT_DATABASE = AP
CREATE USER James FOR LOGIN Fall2022
ALTER ROLE PaymentEntry ADD MEMBER James

-- 3.	Using the Management Studio (do not write a query), create a login ID named “DBMSFall2022” with the password “Fall2022” and set the default database to the AP database. Then, grant the login ID access to the AP database, create a user for the login ID named “Hanna” and assign the user to the PaymentEntry role you created in question 1.
-- In server > Sercuity, right click and select new > login, to create login info
-- Navigate through AP > Security > Users, right click on users to create new useres; clikc on roles to create new roles

-- 4.	Write a script that (1) creates a schema named as your own name, (2) transfers the table named ContactUpdates from the dbo schema to your schema, (3) assigns the Admin schema as the default schema for the user named ‘James’ that you created in question 2, (4) grants all standard privileges except for REFERENCES and ALTER to ‘John’ for your schema.
USE AP
GO
CREATE SCHEMA BEAUTIFUL_NAME
GO
ALTER SCHEMA BEAUTIFUL_NAME TRANSFER dbo.ContactUpdates
GO
ALTER USER James WITH DEFAULT_SCHEMA = Admin
GO
GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE
ON SCHEMA :: BEAUTIFUL_NAME TO James
GO
ALTER USER James WITH NAME = John
GO