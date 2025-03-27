CREATE DATABASE Academy4;
USE Academy4;

CREATE TABLE Curators (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL CHECK (Name != ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname != '')
);

CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Funding MONEY NOT NULL DEFAULT 0,
    CHECK (Name != ''),
    CHECK (Funding >= 0)
);

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name != ''),
    Funding MONEY NOT NULL DEFAULT 0 CHECK (Funding >= 0),
    FacultyId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name != ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL CHECK (Name != ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname != ''),
    Salary MONEY NOT NULL CHECK (Salary > 0)
);

CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name != '')
);

CREATE TABLE Lectures (
    Id INT PRIMARY KEY IDENTITY(1,1),
    LectureRoom NVARCHAR(MAX) NOT NULL CHECK (LectureRoom != ''),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

INSERT INTO Curators (Name, Surname) VALUES
('Olena', 'Petrova'),
('Ihor', 'Koval'),
('Natalia', 'Shevchenko'),
('Samantha', 'Adams');

INSERT INTO Faculties (Name, Funding) VALUES
('Computer Science', 500000),
('Mathematics', 450000),
('Engineering', 600000);

INSERT INTO Departments (Name, Funding, FacultyId) VALUES
('Software Engineering', 200000, 1),
('Data Science', 180000, 1),
('Applied Mathematics', 150000, 2),
('Mechanical Engineering', 250000, 3);

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('P107', 4, 1),
('P108', 3, 1),
('M201', 5, 2),
('E301', 2, 3);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

INSERT INTO Teachers (Name, Surname, Salary) VALUES
('John', 'Smith', 5000),
('Emily', 'Johnson', 5500),
('Michael', 'Williams', 4800),
('Samantha', 'Adams', 6000);

INSERT INTO Subjects (Name) VALUES
('Database Theory'),
('Programming Fundamentals'),
('Machine Learning'),
('Digital Electronics');

INSERT INTO Lectures (LectureRoom, SubjectId, TeacherId) VALUES
('B103', 1, 1),
('A205', 2, 2),
('B103', 3, 4),
('C102', 4, 3);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1),
(1, 3),
(2, 2),
(3, 4);

SELECT t.Name AS TeacherName, t.Surname AS TeacherSurname,
       g.Name AS GroupName
FROM Teachers t
JOIN Groups g ON t.Id = g.Id; -- Assuming a join condition

SELECT f.Name AS FacultyName
FROM Faculties f
JOIN Departments d ON d.FacultyId = f.Id
WHERE d.Funding > f.Funding
GROUP BY f.Name;

SELECT c.Surname AS CuratorSurname, g.Name AS GroupName
FROM Curators c
JOIN GroupsCurators gc ON gc.CuratorId = c.Id
JOIN Groups g ON g.Id = gc.GroupId;

SELECT DISTINCT t.Name, t.Surname
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE g.Name = 'P107';

SELECT DISTINCT t.Surname, f.Name AS FacultyName
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId;

SELECT d.Name AS DepartmentName, g.Name AS GroupName
FROM Departments d
JOIN Groups g ON g.DepartmentId = d.Id;

SELECT DISTINCT s.Name AS SubjectName
FROM Subjects s
JOIN Lectures l ON l.SubjectId = s.Id
JOIN Teachers t ON t.Id = l.TeacherId
WHERE t.Name = 'Samantha' AND t.Surname = 'Adams';

SELECT DISTINCT d.Name AS DepartmentName
FROM Departments d
JOIN Groups g ON g.DepartmentId = d.Id
JOIN GroupsLectures gl ON gl.GroupId = g.Id
JOIN Lectures l ON l.Id = gl.LectureId
JOIN Subjects s ON s.Id = l.SubjectId
WHERE s.Name = 'Database Theory';

SELECT g.Name AS GroupName
FROM Groups g
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId
WHERE f.Name = 'Computer Science';

SELECT g.Name AS GroupName, f.Name AS FacultyName
FROM Groups g
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId
WHERE g.Year = 5;

SELECT
    t.Name + ' ' + t.Surname AS FullName,
    s.Name AS SubjectName,
    g.Name AS GroupName
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN Subjects s ON s.Id = l.SubjectId
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE l.LectureRoom = 'B103';