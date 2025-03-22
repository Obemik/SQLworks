CREATE DATABASE Academy3;
GO

USE Academy3;
GO

CREATE TABLE Faculties (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
    FacultyId INT NOT NULL FOREIGN KEY REFERENCES Faculties(Id)
);

CREATE TABLE Teachers (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Salary MONEY NOT NULL CHECK (Salary > 0),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE Groups (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE Subjects (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Lectures (
    Id INT IDENTITY PRIMARY KEY,
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    LectureRoom NVARCHAR(MAX) NOT NULL,
    SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id),
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id)
);

INSERT INTO Faculties (Name) VALUES
('Computer Science'), ('Information Technology');

INSERT INTO Departments (Name, Financing, FacultyId) VALUES
('Software Development', 100000, 1),
('Network Engineering', 80000, 2);

INSERT INTO Teachers (Name, Surname, Salary, DepartmentId) VALUES
('Dave', 'McQueen', 3000, 1),
('Jack', 'Underhill', 3500, 1),
('Sarah', 'Lee', 3200, 2);

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('CS101', 1, 1),
('CS102', 2, 1),
('NE201', 2, 2);

INSERT INTO Subjects (Name) VALUES
('Databases'), ('Operating Systems'), ('Networks');

INSERT INTO Lectures (DayOfWeek, LectureRoom, SubjectId, TeacherId) VALUES
(1, 'D201', 1, 1),
(2, 'D202', 2, 1),
(3, 'D201', 3, 2),
(4, 'D203', 1, 3),
(5, 'D201', 2, 3);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1), (2, 2), (3, 3), (1, 4), (2, 5);

SELECT COUNT(*) FROM Teachers
JOIN Departments ON Teachers.DepartmentId = Departments.Id
WHERE Departments.Name = 'Software Development';

SELECT COUNT(*) FROM Lectures
JOIN Teachers ON Lectures.TeacherId = Teachers.Id
WHERE Teachers.Name = 'Dave' AND Teachers.Surname = 'McQueen';

SELECT COUNT(*) FROM Lectures
WHERE LectureRoom = 'D201';

SELECT LectureRoom, COUNT(*)
FROM Lectures
GROUP BY LectureRoom;

SELECT COUNT(DISTINCT GroupId)
FROM GroupsLectures
JOIN Lectures ON GroupsLectures.LectureId = Lectures.Id
JOIN Teachers ON Lectures.TeacherId = Teachers.Id
WHERE Teachers.Name = 'Jack' AND Teachers.Surname = 'Underhill';

SELECT AVG(Salary)
FROM Teachers
JOIN Departments ON Teachers.DepartmentId = Departments.Id
JOIN Faculties ON Departments.FacultyId = Faculties.Id
WHERE Faculties.Name = 'Computer Science';

SELECT MIN(StudentCount), MAX(StudentCount)
FROM (
    SELECT COUNT(*) AS StudentCount
    FROM GroupsLectures
    GROUP BY GroupId
) AS GroupStudentCounts;

SELECT AVG(Financing)
FROM Departments;

SELECT CONCAT(Name, ' ', Surname), COUNT(DISTINCT SubjectId)
FROM Teachers
JOIN Lectures ON Teachers.Id = Lectures.TeacherId
GROUP BY Name, Surname;

SELECT DayOfWeek, COUNT(*)
FROM Lectures
GROUP BY DayOfWeek
ORDER BY DayOfWeek;

SELECT LectureRoom, COUNT(DISTINCT Departments.Id)
FROM Lectures
JOIN Teachers ON Lectures.TeacherId = Teachers.Id
JOIN Departments ON Teachers.DepartmentId = Departments.Id
GROUP BY LectureRoom;

SELECT Faculties.Name, COUNT(DISTINCT Subjects.Id)
FROM Lectures
JOIN Subjects ON Lectures.SubjectId = Subjects.Id
JOIN Teachers ON Lectures.TeacherId = Teachers.Id
JOIN Departments ON Teachers.DepartmentId = Departments.Id
JOIN Faculties ON Departments.FacultyId = Faculties.Id
GROUP BY Faculties.Name;

SELECT CONCAT(Teachers.Name, ' ', Teachers.Surname), LectureRoom, COUNT(*)
FROM Lectures
JOIN Teachers ON Lectures.TeacherId = Teachers.Id
GROUP BY Teachers.Name, Teachers.Surname, LectureRoom;
