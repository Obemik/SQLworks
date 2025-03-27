CREATE DATABASE Hospital5;
go
USE Hospital5;
go

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Diseases (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Doctors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Salary MONEY NOT NULL CHECK (Salary > 0)
);

CREATE TABLE Interns (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id)
);

CREATE TABLE Professors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id)
);

CREATE TABLE Wards (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE,
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE Examinations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    DiseaseId INT NOT NULL FOREIGN KEY REFERENCES Diseases(Id),
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id),
    ExaminationId INT NOT NULL FOREIGN KEY REFERENCES Examinations(Id),
    WardId INT NOT NULL FOREIGN KEY REFERENCES Wards(Id)
);

INSERT INTO Departments (Building, Financing, Name) VALUES
(5, 30000, 'Ophthalmology'),
(5, 25000, 'Physiotherapy'),
(3, 20000, 'Cardiology');

INSERT INTO Diseases (Name) VALUES
('Flu'),
('COVID-19'),
('Diabetes');

INSERT INTO Doctors (Name, Surname, Salary) VALUES
('John', 'Doe', 5000),
('Jane', 'Smith', 6000),
('Alice', 'Johnson', 4500);

INSERT INTO Interns (DoctorId) VALUES
(1),
(3);

INSERT INTO Professors (DoctorId) VALUES
(2);

INSERT INTO Wards (Name, Places, DepartmentId) VALUES
('Ward A', 20, 1),
('Ward B', 10, 2),
('Ward C', 5, 3);

INSERT INTO Examinations (Name) VALUES
('Blood Test'),
('X-Ray'),
('MRI');

INSERT INTO DoctorsExaminations (Date, DiseaseId, DoctorId, ExaminationId, WardId) VALUES
('2025-03-20', 1, 1, 1, 1),
('2025-03-21', 2, 2, 2, 2),
('2025-03-22', 3, 3, 3, 3);

USE Hospital5;
go

SELECT Name, Places FROM Wards WHERE DepartmentId IN
    (SELECT Id FROM Departments WHERE Building = 5)
    AND Places >= 5
    AND EXISTS (SELECT 1 FROM Wards WHERE DepartmentId = Departments.Id AND Places > 15);

SELECT DISTINCT d.Name FROM Departments d
JOIN DoctorsExaminations de ON d.Id = (SELECT DepartmentId FROM Wards WHERE Id = de.WardId)
WHERE de.Date >= DATEADD(DAY, -7, GETDATE());

SELECT Name FROM Diseases WHERE Id NOT IN
    (SELECT DISTINCT DiseaseId FROM DoctorsExaminations);

SELECT CONCAT(Name, ' ', Surname) FROM Doctors WHERE Id NOT IN
    (SELECT DISTINCT DoctorId FROM DoctorsExaminations);

SELECT Name FROM Departments WHERE Id NOT IN
    (SELECT DISTINCT (SELECT DepartmentId FROM Wards WHERE Id = de.WardId) FROM DoctorsExaminations de);

SELECT Surname FROM Doctors WHERE Id IN (SELECT DoctorId FROM Interns);

SELECT Surname FROM Doctors WHERE Id IN
    (SELECT DoctorId FROM Interns WHERE Salary > (SELECT MIN(Salary) FROM Doctors));

SELECT Name FROM Wards WHERE Places > ALL
    (SELECT Places FROM Wards WHERE DepartmentId IN
    (SELECT Id FROM Departments WHERE Building = 3));

SELECT DISTINCT d.Surname FROM Doctors d
JOIN DoctorsExaminations de ON d.Id = de.DoctorId
JOIN Wards w ON de.WardId = w.Id
JOIN Departments dp ON w.DepartmentId = dp.Id
WHERE dp.Name IN ('Ophthalmology', 'Physiotherapy');

SELECT DISTINCT dp.Name FROM Departments dp
JOIN Wards w ON dp.Id = w.DepartmentId
JOIN DoctorsExaminations de ON w.Id = de.WardId
JOIN Doctors d ON de.DoctorId = d.Id
WHERE d.Id IN (SELECT DoctorId FROM Interns)
AND d.Id IN (SELECT DoctorId FROM Professors);

SELECT CONCAT(d.Name, ' ', d.Surname) AS DoctorName, dp.Name AS DepartmentName
FROM Doctors d
JOIN DoctorsExaminations de ON d.Id = de.DoctorId
JOIN Wards w ON de.WardId = w.Id
JOIN Departments dp ON w.DepartmentId = dp.Id
WHERE dp.Financing > 20000;

SELECT dp.Name FROM Departments dp
JOIN Wards w ON dp.Id = w.DepartmentId
JOIN DoctorsExaminations de ON w.Id = de.WardId
JOIN Doctors d ON de.DoctorId = d.Id
WHERE d.Salary = (SELECT MAX(Salary) FROM Doctors);

SELECT d.Name, COUNT(de.Id) FROM Diseases d
LEFT JOIN DoctorsExaminations de ON d.Id = de.DiseaseId
GROUP BY d.Name;