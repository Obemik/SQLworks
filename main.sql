CREATE DATABASE Hospital2;
GO

USE Hospital2;
GO

CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Doctors (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (LEN(Name) > 0),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Examinations (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN(Name) > 0)
);

CREATE TABLE Wards (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE CHECK (LEN(Name) > 0),
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY PRIMARY KEY,
    EndTime TIME NOT NULL,
    StartTime TIME NOT NULL CHECK (StartTime >= '08:00' AND StartTime <= '18:00'),
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id),
    ExaminationId INT NOT NULL FOREIGN KEY REFERENCES Examinations(Id),
    WardId INT NOT NULL FOREIGN KEY REFERENCES Wards(Id),
    CHECK (EndTime > StartTime)
);

INSERT INTO Departments (Building, Name) VALUES
(1, 'Cardiology'),
(1, 'Neurology'),
(2, 'Orthopedics'),
(3, 'Pediatrics'),
(4, 'Oncology'),
(5, 'Surgery');

INSERT INTO Doctors (Name, Surname, Salary, Premium) VALUES
('Ivan', 'Petrov', 5000, 1000),
('Maria', 'Ivanova', 5500, 800),
('Oleksandr', 'Sydorenko', 6000, 1200),
('Anna', 'Kovalchuk', 4800, 700),
('Volodymyr', 'Melnyk', 5200, 900),
('Tetiana', 'Shevchenko', 5300, 950),
('Dmytro', 'Bondarenko', 5700, 1100);

INSERT INTO Examinations (Name) VALUES
('ECG'),
('Blood Test'),
('X-Ray'),
('MRI'),
('CT Scan'),
('Ultrasound');

INSERT INTO Wards (Name, Places, DepartmentId) VALUES
('Ward A1', 12, 1),
('Ward A2', 8, 1),
('Ward B1', 15, 2),
('Ward B2', 6, 2),
('Ward C1', 20, 3),
('Ward D1', 9, 4),
('Ward E1', 11, 5),
('Ward F1', 14, 6);

INSERT INTO DoctorsExaminations (DoctorId, ExaminationId, WardId, StartTime, EndTime) VALUES
(1, 1, 1, '09:00', '10:00'),
(1, 2, 1, '10:30', '11:30'),
(2, 3, 2, '09:00', '10:00'),
(2, 4, 3, '11:00', '12:00'),
(3, 5, 4, '14:00', '15:00'),
(4, 6, 5, '10:00', '11:00'),
(5, 1, 6, '13:00', '14:00'),
(6, 2, 7, '15:00', '16:00'),
(7, 3, 8, '16:00', '17:00'),
(1, 4, 3, '13:00', '14:00'),
(2, 5, 4, '14:00', '15:00'),
(3, 6, 5, '16:00', '17:00');

SELECT COUNT(*) AS [Кількість палат з місткістю > 10]
FROM Wards
WHERE Places > 10;

SELECT d.Building AS [Корпус], COUNT(w.Id) AS [Кількість палат]
FROM Departments d
LEFT JOIN Wards w ON d.Id = w.DepartmentId
GROUP BY d.Building;

SELECT d.Name AS [Відділення], COUNT(w.Id) AS [Кількість палат]
FROM Departments d
LEFT JOIN Wards w ON d.Id = w.DepartmentId
GROUP BY d.Name;

SELECT d.Name AS [Відділення], SUM(doc.Premium) AS [Сумарна надбавка]
FROM Departments d
JOIN Wards w ON d.Id = w.DepartmentId
JOIN DoctorsExaminations de ON w.Id = de.WardId
JOIN Doctors doc ON de.DoctorId = doc.Id
GROUP BY d.Name;

SELECT d.Name AS [Відділення], COUNT(DISTINCT de.DoctorId) AS [Кількість лікарів]
FROM Departments d
JOIN Wards w ON d.Id = w.DepartmentId
JOIN DoctorsExaminations de ON w.Id = de.WardId
GROUP BY d.Name
HAVING COUNT(DISTINCT de.DoctorId) >= 5;

SELECT COUNT(*) AS [Кількість лікарів], SUM(Salary + Premium) AS [Сумарна зарплата]
FROM Doctors;

SELECT AVG(Salary + Premium) AS [Середня зарплата]
FROM Doctors;

SELECT Name AS [Палата з мінімальною місткістю]
FROM Wards
WHERE Places = (SELECT MIN(Places) FROM Wards);

SELECT d.Building AS [Корпус], SUM(w.Places) AS [Сумарна кількість місць]
FROM Departments d
JOIN Wards w ON d.Id = w.DepartmentId
WHERE d.Building IN (1, 6, 7, 8) AND w.Places > 10
GROUP BY d.Building
HAVING SUM(w.Places) > 100;

