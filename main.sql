CREATE DATABASE Sportshop;
USE Sportshop;
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.EmployeeArchive', 'U') IS NOT NULL DROP TABLE dbo.EmployeeArchive;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(255) UNIQUE,
    Phone NVARCHAR(20),
    RegistrationDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    HireDate DATE DEFAULT GETDATE(),
    TerminationDate DATE NULL
);

CREATE TABLE EmployeeArchive (
    ArchiveID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    HireDate DATE,
    TerminationDate DATE DEFAULT GETDATE()
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(255),
    ProductType NVARCHAR(100),
    Manufacturer NVARCHAR(255),
    QuantityInStock INT DEFAULT 0,
    CostPrice DECIMAL(10,2),
    SellingPrice DECIMAL(10,2),
    CONSTRAINT CHK_PositiveQuantity CHECK (QuantityInStock >= 0)
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    Quantity INT,
    SalePrice DECIMAL(10,2),
    SaleDate DATETIME DEFAULT GETDATE()
);

GO

CREATE TRIGGER trg_UpdateProductQuantity
ON Products
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Products p
        INNER JOIN inserted i ON
            p.ProductName = i.ProductName AND
            p.ProductType = i.ProductType AND
            p.Manufacturer = i.Manufacturer
    )
    BEGIN
        UPDATE p
        SET
            p.QuantityInStock = p.QuantityInStock + i.QuantityInStock,
            p.CostPrice = i.CostPrice,
            p.SellingPrice = i.SellingPrice
        FROM Products p
        INNER JOIN inserted i ON
            p.ProductName = i.ProductName AND
            p.ProductType = i.ProductType AND
            p.Manufacturer = i.Manufacturer;
    END
    ELSE
    BEGIN
        INSERT INTO Products (
            ProductName, ProductType, Manufacturer,
            QuantityInStock, CostPrice, SellingPrice
        )
        SELECT
            ProductName, ProductType, Manufacturer,
            QuantityInStock, CostPrice, SellingPrice
        FROM inserted;
    END
END;

CREATE TRIGGER trg_ArchiveTerminatedEmployee
ON Employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO EmployeeArchive (
        EmployeeID, FirstName, LastName,
        HireDate, TerminationDate
    )
    SELECT
        d.EmployeeID, d.FirstName, d.LastName,
        d.HireDate, GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.EmployeeID = i.EmployeeID
    WHERE d.TerminationDate IS NULL AND i.TerminationDate IS NOT NULL;
END;

CREATE TRIGGER trg_LimitEmployees
ON Employees
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @CurrentEmployeeCount INT;

    SELECT @CurrentEmployeeCount = COUNT(*)
    FROM Employees
    WHERE TerminationDate IS NULL;

    IF @CurrentEmployeeCount >= 6
    BEGIN
        RAISERROR('Cannot add more than 6 active employees.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO Employees (FirstName, LastName, HireDate, TerminationDate)
    SELECT FirstName, LastName, HireDate, TerminationDate
    FROM inserted;
END;

GO

INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890'),
('Jane', 'Smith', 'jane.smith@example.com', '0987654321');

INSERT INTO Employees (FirstName, LastName, HireDate)
VALUES
('Mike', 'Johnson', GETDATE()),
('Sarah', 'Williams', GETDATE());

INSERT INTO Products (ProductName, ProductType, Manufacturer, QuantityInStock, CostPrice, SellingPrice)
VALUES
('Running Shoes', 'Footwear', 'Nike', 10, 50.00, 100.00),
('Football', 'Sports Equipment', 'Adidas', 20, 25.00, 45.00);

INSERT INTO Sales (ProductID, EmployeeID, CustomerID, Quantity, SalePrice)
VALUES
(1, 1, 1, 2, 100.00),
(2, 2, 2, 1, 45.00);

SELECT * FROM Customers;
SELECT * FROM Employees;
SELECT * FROM Products;
SELECT * FROM Sales;
SELECT * FROM EmployeeArchive;