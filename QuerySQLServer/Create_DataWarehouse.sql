-- Create Database for Data Warehouse
CREATE DATABASE DWH;
GO

-- Use new Database
use DWH;
GO

-- == Build dimension table ==
-- Table DimCustomer
CREATE TABLE DimCustomer(
	CustomerID INT PRIMARY KEY,
	CustomerName VARCHAR(100),
	Address Varchar(200),
	CityName VARCHAR(200),
	StateName VARCHAR(200),
	Age INT,
	Gender VARCHAR(10),
	Email VARCHAR(100)
);

-- Table DimAccount
CREATE TABLE DimAccount(
	AccountID INT PRIMARY KEY,
	CustomerID INT,
	AccountType VARCHAR(50),
	Balance INT,
	DateOpened DATETIME2(0),
	Status VARCHAR(50)

	CONSTRAINT FK_Account_Customer
	FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID)
);

-- Table DimBrach
CREATE TABLE DimBranch(
	BranchID INT PRIMARY KEY,
	BranchName VARCHAR(100),
	BranchLocation VARCHAR(100)
);


-- == Build fact table ==
-- Table FactTransaction
CREATE TABLE FactTransaction(
	TransactionID INT PRIMARY KEY,
	AccountID INT,
	TransactionDate DATETIME2(0),
	Amount DECIMAL(10, 4),
	TransactionType VARCHAR(50),
	BranchID INT

	CONSTRAINT FK_FactTransaction_Account
	FOREIGN KEY (AccountID) REFERENCES DimAccount(AccountID),

	CONSTRAINT FK_FactTransaction_Branch
	FOREIGN KEY (BranchID) REFERENCES DimBranch(BranchID)
);
