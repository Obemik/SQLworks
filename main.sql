CREATE DATABASE Sportshop;
GO

USE Sportshop;
GO

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    EmployeeID INT,
    CustomerID INT,
    SellingPrice DECIMAL(10,2),
    Quantity INT,
    SaleDate DATETIME
);
GO

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(255),
    ProductType VARCHAR(100),
    Manufacturer VARCHAR(255),
    QuantityInStock INT
);
GO

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(255),
    Email VARCHAR(255),
    ContactPhone VARCHAR(20),
    Gender CHAR(1),
    DiscountRate DECIMAL(5,2),
    SubscribedToNewsletter BIT
);
GO

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(255),
    HireDate DATE
);
GO

CREATE TABLE History (
    HistoryID INT PRIMARY KEY IDENTITY(1,1),
    SaleID INT,
    ProductID INT,
    EmployeeID INT,
    CustomerID INT,
    SellingPrice DECIMAL(10,2),
    Quantity INT,
    SaleDate DATETIME
);
GO

CREATE TABLE Archive (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(255),
    ProductType VARCHAR(100),
    Manufacturer VARCHAR(255),
    LastSoldDate DATETIME
);
GO

CREATE TABLE LastUnit (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(255),
    Quantity INT
);
GO

CREATE TRIGGER trg_InsertHistory
ON Sales
AFTER INSERT
AS
BEGIN
    INSERT INTO History (SaleID, ProductID, EmployeeID, CustomerID, SellingPrice, Quantity, SaleDate)
    SELECT SaleID, ProductID, EmployeeID, CustomerID, SellingPrice, Quantity, SaleDate
    FROM inserted;
END;
GO

CREATE TRIGGER trg_MoveToArchive
ON Products
AFTER UPDATE
AS
BEGIN
    INSERT INTO Archive (ProductID, ProductName, ProductType, Manufacturer, LastSoldDate)
    SELECT ProductID, ProductName, ProductType, Manufacturer, GETDATE()
    FROM deleted
    WHERE QuantityInStock = 0;

    DELETE FROM Products
    WHERE ProductID IN (SELECT ProductID FROM deleted WHERE QuantityInStock = 0);
END;
GO

CREATE TRIGGER trg_PreventDuplicateCustomer
ON Customers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Customers c
        JOIN inserted i
        ON c.FullName = i.FullName AND c.Email = i.Email
    )
    BEGIN
        RAISERROR ('Customer already exists', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        INSERT INTO Customers (FullName, Email, ContactPhone, Gender, DiscountRate, SubscribedToNewsletter)
        SELECT FullName, Email, ContactPhone, Gender, DiscountRate, SubscribedToNewsletter FROM inserted;
    END
END;
GO

CREATE TRIGGER trg_PreventCustomerDelete
ON Customers
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR ('Customer deletion is not allowed', 16, 1);
    ROLLBACK;
END;
GO

CREATE TRIGGER trg_PreventOldEmployeeDelete
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM deleted WHERE HireDate < '2015-01-01'
    )
    BEGIN
        RAISERROR ('Deleting employees hired before 2015 is not allowed', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM Employees WHERE EmployeeID IN (SELECT EmployeeID FROM deleted);
    END
END;
GO

CREATE TRIGGER trg_CheckTotalPurchases
ON Sales
AFTER INSERT
AS
BEGIN
    UPDATE Customers
    SET DiscountRate = 15
    WHERE CustomerID IN (
        SELECT CustomerID
        FROM Sales
        GROUP BY CustomerID
        HAVING SUM(SellingPrice * Quantity) > 50000
    );
END;
GO

CREATE TRIGGER trg_PreventSpecificManufacturer
ON Products
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Manufacturer = 'Sport, Sun & Barbell')
    BEGIN
        RAISERROR ('Adding products from "Sport, Sun & Barbell" is not allowed', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        INSERT INTO Products (ProductName, ProductType, QuantityInStock, Manufacturer)
        SELECT ProductName, ProductType, QuantityInStock, Manufacturer FROM inserted;
    END
END;
GO

CREATE TRIGGER trg_LastUnit
ON Products
AFTER UPDATE
AS
BEGIN
    INSERT INTO LastUnit (ProductID, ProductName, Quantity)
    SELECT ProductID, ProductName, QuantityInStock
    FROM inserted
    WHERE QuantityInStock = 1;
END;
GO

INSERT INTO Customers (FullName, Email, ContactPhone, Gender, DiscountRate, SubscribedToNewsletter)
VALUES ('John Doe', 'john.doe@example.com', '1234567890', 'M', 0, 1);

INSERT INTO Products (ProductName, ProductType, QuantityInStock, Manufacturer)
VALUES ('Running Shoes', 'Footwear', 10, 'Nike');

INSERT INTO Sales (ProductID, EmployeeID, CustomerID, SellingPrice, Quantity, SaleDate)
VALUES (1, 1, 1, 100, 2, GETDATE());

SELECT * FROM History;
SELECT * FROM Archive;
SELECT * FROM LastUnit;