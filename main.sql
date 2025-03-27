CREATE DATABASE Hospital4;
USE Hospital4;

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Building INT CHECK (Building BETWEEN 1 AND 5) NOT NULL,
    Name NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Doctors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Premium MONEY DEFAULT 0 CHECK (Premium >= 0) NOT NULL,
    Salary MONEY CHECK (Salary > 0) NOT NULL
);

CREATE TABLE Sponsors (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Examinations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Wards (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(20) UNIQUE NOT NULL,
    Places INT CHECK (Places >= 1) NOT NULL,
    DepartmentId INT NOT NULL
);

CREATE TABLE Donations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Amount MONEY CHECK (Amount > 0) NOT NULL,
    Date DATE DEFAULT GETDATE() CHECK (Date <= GETDATE()) NOT NULL,
    DepartmentId INT NOT NULL,
    SponsorId INT NOT NULL
);

CREATE TABLE DoctorsExaminations (
    Id INT PRIMARY KEY IDENTITY(1,1),
    DoctorId INT NOT NULL,
    ExaminationId INT NOT NULL,
    WardId INT NOT NULL,
    StartTime TIME CHECK (StartTime BETWEEN '08:00' AND '18:00') NOT NULL,
    EndTime TIME NOT NULL,
    CONSTRAINT CHK_EndTime CHECK (EndTime > StartTime)
);

ALTER TABLE Wards
ADD CONSTRAINT FK_Wards_Departments
FOREIGN KEY (DepartmentId) REFERENCES Departments(Id);

ALTER TABLE Donations
ADD CONSTRAINT FK_Donations_Departments
FOREIGN KEY (DepartmentId) REFERENCES Departments(Id);

ALTER TABLE Donations
ADD CONSTRAINT FK_Donations_Sponsors
FOREIGN KEY (SponsorId) REFERENCES Sponsors(Id);

ALTER TABLE DoctorsExaminations
ADD CONSTRAINT FK_DoctorsExaminations_Doctors
FOREIGN KEY (DoctorId) REFERENCES Doctors(Id);

ALTER TABLE DoctorsExaminations
ADD CONSTRAINT FK_DoctorsExaminations_Examinations
FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id);

ALTER TABLE DoctorsExaminations
ADD CONSTRAINT FK_DoctorsExaminations_Wards
FOREIGN KEY (WardId) REFERENCES Wards(Id);

INSERT INTO Departments (Building, Name) VALUES
(1, 'Cardiology'),
(2, 'Gastroenterology'),
(2, 'General Surgery'),
(3, 'Microbiology'),
(4, 'Neurology'),
(5, 'Oncology');

INSERT INTO Doctors (Name, Surname, Premium, Salary) VALUES
('Thomas', 'Gerada', 100, 1000),
('Anthony', 'Davis', 200, 1500),
('Joshua', 'Bell', 150, 1200),
('David', 'Wilson', 50, 800),
('Michael', 'Brown', 100, 1100);

INSERT INTO Sponsors (Name) VALUES
('HealthCare Foundation'),
('Medical Research Trust'),
('City Hospital Support'),
('Wellness Donors');

INSERT INTO Examinations (Name) VALUES
('Blood Test'),
('X-Ray'),
('MRI Scan'),
('Ultrasound'),
('CT Scan');

INSERT INTO Wards (Name, Places, DepartmentId) VALUES
('Ward A', 10, 1),
('Ward B', 15, 2),
('Ward C', 12, 3),
('Ward D', 8, 4),
('Ward E', 20, 5);

INSERT INTO Donations (Amount, Date, DepartmentId, SponsorId) VALUES
(5000, '2024-01-15', 1, 1),
(3000, '2024-02-20', 2, 2),
(2000, '2024-03-10', 3, 3),
(1000, '2024-04-05', 4, 4),
(500, '2024-05-01', 5, 1);

INSERT INTO DoctorsExaminations (DoctorId, ExaminationId, WardId, StartTime, EndTime) VALUES
(1, 1, 1, '09:00', '10:30'),
(2, 2, 2, '10:30', '12:00'),
(3, 3, 3, '13:00', '14:30'),
(4, 4, 4, '14:30', '16:00'),
(5, 5, 5, '12:00', '13:30');

SELECT Name
FROM Departments
WHERE Building = (SELECT Building FROM Departments WHERE Name = 'Cardiology')
  AND Name != 'Cardiology';

SELECT Name
FROM Departments
WHERE Building = (SELECT Building FROM Departments WHERE Name = 'Gastroenterology')
  AND Name NOT IN ('Gastroenterology', 'General Surgery');

SELECT TOP 1 d.Name
FROM Departments d
LEFT JOIN Donations don ON d.Id = don.DepartmentId
GROUP BY d.Name
ORDER BY SUM(ISNULL(don.Amount, 0)) ASC;

SELECT Surname
FROM Doctors
WHERE Salary > (SELECT Salary FROM Doctors WHERE Surname = 'Gerada');

SELECT w.Name
FROM Wards w
JOIN Departments d ON w.DepartmentId = d.Id
WHERE w.Places > (
    SELECT AVG(Places)
    FROM Wards
    WHERE DepartmentId = (SELECT Id FROM Departments WHERE Name = 'Microbiology')
);

SELECT Name + ' ' + Surname AS FullName
FROM Doctors
WHERE (Salary + Premium) > (
    SELECT Salary + Premium + 100
    FROM Doctors
    WHERE Name = 'Anthony' AND Surname = 'Davis'
);

SELECT DISTINCT d.Name
FROM Departments d
JOIN Wards w ON d.Id = w.DepartmentId
JOIN DoctorsExaminations de ON w.Id = de.WardId
JOIN Doctors doc ON de.DoctorId = doc.Id
WHERE doc.Name = 'Joshua' AND doc.Surname = 'Bell';

SELECT Name
FROM Sponsors
WHERE Id NOT IN (
    SELECT DISTINCT SponsorId
    FROM Donations d
    JOIN Departments dep ON d.DepartmentId = dep.Id
    WHERE dep.Name IN ('Neurology', 'Oncology')
);

SELECT DISTINCT d.Surname
FROM Doctors d
JOIN DoctorsExaminations de ON d.Id = de.DoctorId
WHERE de.StartTime BETWEEN '12:00' AND '15:00';
