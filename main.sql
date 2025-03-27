CREATE DATABASE Hospital3
GO
USE Hospital3
GO

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE
)
GO

CREATE TABLE Doctors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0)
)
GO

CREATE TABLE Specializations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE
)
GO

CREATE TABLE DoctorsSpecializations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id),
    SpecializationId INT NOT NULL FOREIGN KEY REFERENCES Specializations(Id)
)
GO

CREATE TABLE Vacations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id),
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CHECK (EndDate > StartDate)
)
GO

CREATE TABLE Sponsors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE
)
GO

CREATE TABLE Donations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Amount MONEY NOT NULL CHECK (Amount > 0),
    Date DATE NOT NULL DEFAULT GETDATE() CHECK (Date <= GETDATE()),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id),
    SponsorId INT NOT NULL FOREIGN KEY REFERENCES Sponsors(Id)
)
GO

CREATE TABLE Wards (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(20) NOT NULL UNIQUE,
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
)
GO

INSERT INTO Departments (Name) VALUES
('Intensive Treatment'),
('Cardiology'),
('Neurology'),
('Pediatrics')
GO

INSERT INTO Sponsors (Name) VALUES
('Umbrella Corporation'),
('Health First Foundation'),
('Medical Innovations Inc.')
GO

INSERT INTO Specializations (Name) VALUES
('Surgeon'),
('Therapist'),
('Neurologist'),
('Pediatrician')
GO

INSERT INTO Doctors (Name, Surname, Salary, Premium) VALUES
('Helen', 'Williams', 5000, 1000),
('John', 'Smith', 4500, 0),
('Maria', 'Garcia', 5500, 500),
('David', 'Brown', 4800, 200)
GO

INSERT INTO DoctorsSpecializations (DoctorId, SpecializationId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4)
GO

INSERT INTO Vacations (DoctorId, StartDate, EndDate) VALUES
(1, '2024-01-15', '2024-02-15'),
(3, '2024-03-01', '2024-03-20')
GO

INSERT INTO Donations (Amount, Date, DepartmentId, SponsorId) VALUES
(150000, '2024-03-01', 1, 1),
(80000, '2024-02-15', 2, 2),
(120000, '2024-03-10', 3, 3)
GO

INSERT INTO Wards (Name, DepartmentId) VALUES
('Ward A', 1),
('Ward B', 2),
('Ward C', 3),
('Ward D', 4)
GO

SELECT DISTINCT d.Name + ' ' + d.Surname AS FullName, s.Name AS Specialization
FROM Doctors d
JOIN DoctorsSpecializations ds ON d.Id = ds.DoctorId
JOIN Specializations s ON ds.SpecializationId = s.Id

SELECT d.Surname, (d.Salary + d.Premium) AS TotalSalary
FROM Doctors d
LEFT JOIN Vacations v ON d.Id = v.DoctorId
WHERE v.Id IS NULL

SELECT w.Name AS WardName
FROM Wards w
JOIN Departments d ON w.DepartmentId = d.Id
WHERE d.Name = 'Intensive Treatment'

SELECT DISTINCT d.Name
FROM Departments d
JOIN Donations don ON d.Id = don.DepartmentId
JOIN Sponsors s ON don.SponsorId = s.Id
WHERE s.Name = 'Umbrella Corporation'

SELECT d.Name AS Department, s.Name AS Sponsor,
       don.Amount AS DonationAmount, don.Date AS DonationDate
FROM Donations don
JOIN Departments d ON don.DepartmentId = d.Id
JOIN Sponsors s ON don.SponsorId = s.Id
WHERE don.Date >= DATEADD(MONTH, -1, GETDATE())

SELECT
    d.Name + ' ' + d.Surname AS DoctorName,
    dep.Name AS Department
FROM Doctors d
CROSS JOIN Departments dep

SELECT
    w.Name AS WardName,
    dep.Name AS DepartmentName
FROM Wards w
JOIN Departments dep ON w.DepartmentId = dep.Id
JOIN Doctors d ON d.Name = 'Helen' AND d.Surname = 'Williams'

SELECT DISTINCT
    dep.Name AS DepartmentName,
    d.Name + ' ' + d.Surname AS DoctorName
FROM Departments dep
JOIN Donations don ON dep.Id = don.DepartmentId
CROSS JOIN Doctors d
WHERE don.Amount > 100000

SELECT DISTINCT dep.Name AS DepartmentName
FROM Departments dep
CROSS JOIN Doctors d

SELECT DISTINCT s.Name AS SpecializationName
FROM Specializations s

SELECT DISTINCT
    dep.Name AS DepartmentName
FROM Departments dep

SELECT
    dep.Name AS DepartmentName,
    w.Name AS WardName
FROM Departments dep
JOIN Wards w ON dep.Id = w.DepartmentId