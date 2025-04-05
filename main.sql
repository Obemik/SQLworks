CREATE DATABASE FruitsAndVegetables1;
GO

USE FruitsAndVegetables1;
GO

CREATE TABLE Products (
    Id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Type NVARCHAR(10) NOT NULL CHECK (Type IN ('Vegetable', 'Fruit')),
    Color NVARCHAR(50) NOT NULL,
    Calories INT NOT NULL CHECK (Calories >= 0)
);
GO

INSERT INTO Products (Name, Type, Color, Calories) VALUES
    ('Apple', 'Fruit', 'Red', 52),
    ('Banana', 'Fruit', 'Yellow', 89),
    ('Carrot', 'Vegetable', 'Orange', 41),
    ('Cucumber', 'Vegetable', 'Green', 15),
    ('Tomato', 'Vegetable', 'Red', 18),
    ('Orange', 'Fruit', 'Orange', 47),
    ('Potato', 'Vegetable', 'Brown', 77);
GO
