-- 1.	Create a new database named School.
USE MASTER
GO

IF DB_ID('School') IS NOT NULL
	DROP DATABASE School
GO

CREATE DATABASE School
GO

-- 2.	(1) Describe the relationship type shown in figure (one-to-one, one-to-many or many-to-many). (2) Write the CREATE TABLE statements needed to implement the followind design in the School database. Include foreign key constraints. Define StudentID and CourseID as identity columns. Decide which columns should allow null values, if any, and explain your decision. Define the Course Price column with a default zero and a check constraint to allow only positive values.
USE School
GO
CREATE TABLE Students(
	StudentID	INT		NOT NULL	IDENTITY	PRIMARY KEY,
	FirstName	VARCHAR(50)	NULL,
	LastName	VARCHAR(50) NULL,
	Phone		VARCHAR(50)	NULL,
)
GO

CREATE TABLE Courses(
	CourseID	INT		NOT NULL	IDENTITY	PRIMARY KEY,
	CourseName	VARCHAR(50) NULL,	
	CoursePrice	MONEY	NULL		DEFAULT 0	
		CHECK (CoursePrice >= 0),
)
GO

CREATE TABLE StudyGroups(
	StudentID	INT		NOT NULL	REFERENCES
		Students (StudentID),
	CourseID	INT		NOT NULL	REFERENCES
		Courses (CourseID),
	PRIMARY KEY (StudentID, CourseID)
)
GO

-- 3.	Write the CREATE INDEX statements to create a clustered index on the StudentID column and a nonclustered index on the CourseID column of the StudyGroups table.
USE School
GO
CREATE CLUSTERED INDEX IX_Students ON
	Students (StudentID ASC);
GO

CREATE NONCLUSTERED INDEX IX_Courses ON
	StudyGroups (CourseID ASC)
GO

-- 4.	Write an ALTER TABLE statement that adds a new column, CourseFeePaid, to the Students table. Use the bit data type, disallow null values, and assign a default Boolean value of False.

USE School
GO
ALTER TABLE Students 
ADD CourseFeePaid BIT NULL DEFAULT 0

-- 5.	Write an ALTER TABLE statement that adds two new check constraints to the Invoices table in the AP database. The first should allow (1) PaymentDate to be null only if PaymentTotal is zero and (2) PaymentDate to be not null only if PaymentTotal is greater than zero. The second constraint should prevent the sum of PaymentTotal and CreditTotal from being greater than InvoiceTotal.
USE AP
GO
ALTER TABLE Invoices WITH NOCHECK
ADD 
CONSTRAINT PaymentDate_check CHECK (
	((PaymentDate = NULL) AND (PaymentTotal = 0)) AND
	((PaymentDate IS NOT NULL) AND (PaymentTotal>0))
	),
CONSTRAINT Credit_check CHECK(
	PaymentTotal+CreditTotal <= InvoiceTotal
)
GO

-- 6.	Delete the StudyGroups table from the School database. Then, write a CREATE TABLE statement that recreates the table, this time with a unique constraint that prevents a student from being a study-group member in the same course twice.
USE School
GO
DROP TABLE StudyGroups;
GO
CREATE TABLE StudyGroups(
	StudentID	INT		NOT NULL	UNIQUE		REFERENCES
		Students (StudentID),
	CourseID	INT		NOT NULL	UNIQUE		REFERENCES
		Courses (CourseID),
	PRIMARY KEY (StudentID, CourseID),
)
GO

-- 7.	Use the Management Studio to create a new database called College using the default settings. (Do not use SQL query to do this).
-- Operate on SSMS with GUI interface