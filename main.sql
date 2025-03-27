CREATE DATABASE Academy5;
USE Academy5;

CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    FacultyId INT NOT NULL
);

CREATE TABLE Curators (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL CHECK (Name != ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname != '')
);

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IsProfessor BIT NOT NULL DEFAULT 0,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name != ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname != '')
);

CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name != ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL
);

CREATE TABLE GroupsCurators (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL
);

CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name != '')
);

CREATE TABLE Lectures (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Date DATE NOT NULL CHECK (Date <= GETDATE()),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL
);

CREATE TABLE Students (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL CHECK (Name != ''),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname != '')
);

CREATE TABLE GroupsStudents (
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL,
    StudentId INT NOT NULL
);

CREATE TABLE GroupsLectures (
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL,
    LectureId INT NOT NULL
);

ALTER TABLE Departments
ADD FOREIGN KEY (FacultyId) REFERENCES Faculties(Id);

ALTER TABLE Groups
ADD FOREIGN KEY (DepartmentId) REFERENCES Departments(Id);

ALTER TABLE GroupsCurators
ADD FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id);

ALTER TABLE Lectures
ADD FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id);

ALTER TABLE GroupsStudents
ADD FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (StudentId) REFERENCES Students(Id);

ALTER TABLE GroupsLectures
ADD FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id);

INSERT INTO Faculties (Name) VALUES
('Computer Science'),
('Engineering'),
('Mathematics');

INSERT INTO Departments (Building, Financing, Name, FacultyId) VALUES
(1, 150000, 'Software Development', 1),
(2, 120000, 'Cybersecurity', 1),
(3, 100000, 'Mechanical Engineering', 2),
(4, 80000, 'Applied Mathematics', 3);

INSERT INTO Curators (Name, Surname) VALUES
('Maria', 'Petrova'),
('Ivan', 'Sidorov'),
('Olena', 'Kovalenko');

INSERT INTO Teachers (IsProfessor, Name, Salary, Surname) VALUES
(1, 'Oleksii', 7500, 'Ivanov'),
(1, 'Tetiana', 8000, 'Melnyk'),
(0, 'Petro', 5500, 'Onyshchenko'),
(1, 'Nataliia', 7200, 'Kravenko');

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('D221', 5, 1),
('D222', 5, 1),
('E321', 3, 2),
('M411', 4, 4);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);

INSERT INTO Subjects (Name) VALUES
('Fundamentals of Programming'),
('Cybersecurity'),
('Machine Learning'),
('Linear Algebra');

INSERT INTO Students (Name, Rating, Surname) VALUES
('Anna', 4, 'Petrenko'),
('Mykola', 5, 'Ivanchuk'),
('Oksana', 3, 'Sidorenko'),
('Dmytro', 4, 'Melnychuk');

INSERT INTO GroupsStudents (GroupId, StudentId) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);

INSERT INTO Lectures (Date, SubjectId, TeacherId) VALUES
('2024-03-01', 1, 1),
('2024-03-02', 2, 2),
('2024-03-03', 3, 3),
('2024-03-04', 4, 4);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

SELECT DISTINCT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

SELECT DISTINCT g.Name
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
WHERE d.Name = 'Software Development' AND g.Year = 5;

WITH GroupRatings AS (
    SELECT g.Id, g.Name, AVG(s.Rating) as AvgRating
    FROM Groups g
    JOIN GroupsStudents gs ON g.Id = gs.GroupId
    JOIN Students s ON gs.StudentId = s.Id
    GROUP BY g.Id, g.Name
)
SELECT Name
FROM GroupRatings
WHERE AvgRating > (SELECT AvgRating FROM GroupRatings WHERE Name = 'D221');

SELECT Name, Surname
FROM Teachers
WHERE Salary > (SELECT AVG(Salary) FROM Teachers WHERE IsProfessor = 1);

SELECT g.Name
FROM Groups g
JOIN GroupsCurators gc ON g.Id = gc.GroupId
GROUP BY g.Name
HAVING COUNT(gc.CuratorId) > 1;

WITH GroupRatings AS (
    SELECT g.Id, g.Name, AVG(s.Rating) as AvgRating
    FROM Groups g
    JOIN GroupsStudents gs ON g.Id = gs.GroupId
    JOIN Students s ON gs.StudentId = s.Id
    GROUP BY g.Id, g.Name
), FifthYearRatings AS (
    SELECT MIN(AvgRating) as MinRating
    FROM GroupRatings gr
    JOIN Groups g ON gr.Id = g.Id
    WHERE g.Year = 5
)
SELECT Name
FROM GroupRatings, FifthYearRatings
WHERE AvgRating < MinRating;

SELECT f.Name
FROM Faculties f
JOIN Departments d ON f.Id = d.FacultyId
GROUP BY f.Name
HAVING SUM(d.Financing) > (
    SELECT SUM(Financing)
    FROM Departments d2
    JOIN Faculties f2 ON d2.FacultyId = f2.Id
    WHERE f2.Name = 'Computer Science'
);

WITH LectureCounts AS (
    SELECT
        s.Name as SubjectName,
        t.Name + ' ' + t.Surname as TeacherFullName,
        COUNT(l.Id) as LectureCount,
        RANK() OVER (PARTITION BY s.Name ORDER BY COUNT(l.Id) DESC) as Ranking
    FROM Lectures l
    JOIN Subjects s ON l.SubjectId = s.Id
    JOIN Teachers t ON l.TeacherId = t.Id
    GROUP BY s.Name, t.Name, t.Surname
)
SELECT SubjectName, TeacherFullName
FROM LectureCounts
WHERE Ranking = 1;

WITH LectureCounts AS (
    SELECT
        s.Name as SubjectName,
        COUNT(l.Id) as LectureCount,
        RANK() OVER (ORDER BY COUNT(l.Id)) as Ranking
    FROM Subjects s
    LEFT JOIN Lectures l ON s.Id = l.SubjectId
    GROUP BY s.Name
)
SELECT SubjectName
FROM LectureCounts
WHERE Ranking = 1;

SELECT
    (SELECT COUNT(*) FROM Students s
    JOIN GroupsStudents gs ON s.Id = gs.StudentId
    JOIN Groups g ON gs.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    WHERE d.Name = 'Software Development') as StudentCount,
    (SELECT COUNT(*) FROM Subjects s
    JOIN Lectures l ON s.Id = l.SubjectId
    JOIN Teachers t ON l.TeacherId = t.Id
    JOIN Departments d ON t.Id IN (
        SELECT Id FROM Teachers
        WHERE Id IN (SELECT TeacherId FROM Lectures)
    )
    JOIN Groups g ON d.Id = g.DepartmentId
    WHERE d.Name = 'Software Development') as SubjectCount;