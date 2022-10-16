USE master
GO

IF DB_ID('ORDERS') IS NOT NULL
	DROP DATABASE Orders
GO

CREATE DATABASE Orders
GO

USE Orders
GO

CREATE TABLE Customers(
	CustomerID int IDENTITY(1,1) NOT NULL,
	CustomerName varchar(50) NULL,
	Address varchar(50) NULL,
	Email varchar(50) NULL,
	Phone varchar(50) NULL
)
GO

CREATE TABLE Orders(
	OrderID int IDENTITY(1,1) NOT NULL,
	CustomerID int NOT NULL,
	OrderDate smalldatetime NOT NULL,
	ShipDate smalldatetime NULL,
	Price smallmoney NOT NULL
)
GO

CREATE TABLE OrderItem(
	OrderID int NOT NULL,
	ProductID int NOT NULL,
	Quantity int NOT NULL,
	UnitPrice smallmoney NOT NULL
)
GO

CREATE TABLE Products(
	ProductID int IDENTITY(1,1) NOT NULL,
	ProductName varchar(50) NOT NULL,
	Price smallmoney NOT NULL,
	InStock bit NULL,
	OnOrder bit NULL,
)
GO

CREATE TABLE Shipping(
	ShippingID int IDENTITY(1,1) NOT NULL,
	OrderID int NOT NULL,
	ShipperName varchar(50) NOT NULL,
	ShipperPhone varchar(50) NULL,
	Weight float NOT NULL,
	ShippingDate smalldatetime NOT NULL,
	ShippingMedium varchar(50) NULL
)
GO

CREATE TABLE Employees(
	EmployeeID int IDENTITY(1,1) NOT NULL,
	SSN varchar(50) NOT NULL,
	FirstName varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	DepartmentName varchar(50) NOT NULL,
	HireDate smalldatetime NOT NULL,
	HomeAddress varchar(50) NULL,
	Phone varchar(50) NULL,
	Email varchar(50) NULL
)
GO