CREATE DATABASE HospitalDB2;
GO

USE HospitalDB2;
GO

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Floor INT NOT NULL CHECK (Floor >= 1),
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Diseases (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Severity INT NOT NULL DEFAULT 1 CHECK (Severity >= 1)
);

CREATE TABLE Doctors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Phone CHAR(10) NOT NULL,
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0)
);

CREATE TABLE Examinations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    EndTime TIME NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    StartTime TIME NOT NULL CHECK (StartTime BETWEEN '08:00' AND '18:00')
);

CREATE TABLE Wards (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Floor INT NOT NULL CHECK (Floor >= 1),
    Name NVARCHAR(20) NOT NULL UNIQUE
);

INSERT INTO Departments (Building, Financing, Floor, Name)
VALUES (3, 14000, 2, 'Cardiology'),
       (5, 28000, 3, 'Neurology'),
       (3, 12000, 1, 'Pediatrics'),
       (4, 9000, 1, 'Oncology'),
       (5, 32000, 1, 'Orthopedics');

INSERT INTO Diseases (Name, Severity)
VALUES ('Flu', 2),
       ('Covid-19', 4),
       ('Chickenpox', 1),
       ('Pneumonia', 3);

INSERT INTO Doctors (Name, Surname, Phone, Premium, Salary)
VALUES ('John', 'Doe', '1234567890', 200, 1500),
       ('Jane', 'Norton', '0987654321', 300, 1600),
       ('Mark', 'Smith', '1112223334', 150, 1400),
       ('Lucy', 'Nelson', '2223334445', 400, 2000);

INSERT INTO Examinations (DayOfWeek, EndTime, Name, StartTime)
VALUES (1, '13:00', 'MRI Scan', '12:00'),
       (2, '14:30', 'Blood Test', '12:30'),
       (3, '15:00', 'X-Ray', '13:00'),
       (5, '16:00', 'Ultrasound', '14:00');

INSERT INTO Wards (Building, Floor, Name)
VALUES (4, 1, 'Ward A'),
       (5, 1, 'Ward B'),
       (3, 2, 'Ward C'),
       (5, 3, 'Ward D'),
       (1, 1, 'Ward E');

SELECT * FROM Wards;
SELECT Surname, Phone FROM Doctors;
SELECT DISTINCT Floor FROM Wards;
SELECT Name AS "Name of Disease", Severity AS "Severity of Disease" FROM Diseases;
SELECT d.Name AS DoctorName, dep.Name AS DepartmentName, w.Name AS WardName
FROM Doctors d
JOIN Departments dep ON d.Id = dep.Id
JOIN Wards w ON dep.Id = w.Id;
SELECT Name FROM Departments WHERE Building = 5 AND Financing < 30000;
SELECT Name FROM Departments WHERE Building = 3 AND Financing BETWEEN 12000 AND 15000;
SELECT Name FROM Wards WHERE Building IN (4, 5) AND Floor = 1;
SELECT Name, Building, Financing FROM Departments
WHERE Building IN (3, 6) AND (Financing < 11000 OR Financing > 25000);
SELECT Surname FROM Doctors WHERE Salary + Premium > 1500;
SELECT Surname FROM Doctors WHERE (Salary / 2) > (Premium * 3);
SELECT DISTINCT Name FROM Examinations
WHERE DayOfWeek IN (1, 2, 3) AND StartTime >= '12:00' AND EndTime <= '15:00';
SELECT Name, Building FROM Departments WHERE Building IN (1, 3, 8, 10);
SELECT Name FROM Diseases WHERE Severity NOT IN (1, 2);
SELECT Name FROM Departments WHERE Building NOT IN (1, 3);
SELECT Name FROM Departments WHERE Building IN (1, 3);
SELECT Surname FROM Doctors WHERE Surname LIKE 'N%';
