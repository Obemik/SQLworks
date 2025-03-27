CREATE DATABASE Academy6;
USE Academy6;

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL
);

CREATE TABLE Assistants (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE Curators (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE Deans (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE Heads (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY,
    Building INT NOT NULL CHECK(Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) UNIQUE NOT NULL,
    DeanId INT NOT NULL FOREIGN KEY REFERENCES Deans(Id)
);

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY,
    Building INT NOT NULL CHECK(Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) UNIQUE NOT NULL,
    FacultyId INT NOT NULL FOREIGN KEY REFERENCES Faculties(Id),
    HeadId INT NOT NULL FOREIGN KEY REFERENCES Heads(Id)
);

CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(10) UNIQUE NOT NULL,
    Year INT NOT NULL CHECK(Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators (
    Id INT PRIMARY KEY IDENTITY,
    CuratorId INT NOT NULL FOREIGN KEY REFERENCES Curators(Id),
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id)
);

CREATE TABLE LectureRooms (
    Id INT PRIMARY KEY IDENTITY,
    Building INT NOT NULL CHECK(Building BETWEEN 1 AND 5),
    Name NVARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Lectures (
    Id INT PRIMARY KEY IDENTITY,
    SubjectId INT NOT NULL FOREIGN KEY REFERENCES Subjects(Id),
    TeacherId INT NOT NULL FOREIGN KEY REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT PRIMARY KEY IDENTITY,
    GroupId INT NOT NULL FOREIGN KEY REFERENCES Groups(Id),
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id)
);

CREATE TABLE Schedules (
    Id INT PRIMARY KEY IDENTITY,
    Class INT NOT NULL CHECK(Class BETWEEN 1 AND 8),
    DayOfWeek INT NOT NULL CHECK(DayOfWeek BETWEEN 1 AND 7),
    Week INT NOT NULL CHECK(Week BETWEEN 1 AND 52),
    LectureId INT NOT NULL FOREIGN KEY REFERENCES Lectures(Id),
    LectureRoomId INT NOT NULL FOREIGN KEY REFERENCES LectureRooms(Id)
);

INSERT INTO Teachers (Name, Surname) VALUES
('Edward', 'Hopper'),
('Alex', 'Carmack'),
('Michael', 'Brown');

INSERT INTO Assistants (TeacherId) VALUES (3);

INSERT INTO Deans (TeacherId) VALUES (1);

INSERT INTO Faculties (Building, Name, DeanId) VALUES
(1, 'Computer Science', 1);

INSERT INTO Heads (TeacherId) VALUES (2);

INSERT INTO Departments (Building, Name, FacultyId, HeadId) VALUES
(1, 'Software Development', 1, 1);

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('F505', 5, 1);

INSERT INTO Subjects (Name) VALUES
('Mathematics'),
('Programming');

INSERT INTO Lectures (SubjectId, TeacherId) VALUES
(1, 1),
(2, 2);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1),
(1, 2);

INSERT INTO LectureRooms (Building, Name) VALUES
(1, 'A311'),
(1, 'A104');

INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES
(3, 3, 2, 1, 1),
(3, 3, 2, 2, 2);

SELECT DISTINCT lr.Name
FROM LectureRooms lr
JOIN Schedules s ON lr.Id = s.LectureRoomId
JOIN Lectures l ON s.LectureId = l.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

SELECT DISTINCT t.Surname
FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE g.Name = 'F505';

SELECT DISTINCT s.Name
FROM Subjects s
JOIN Lectures l ON s.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack' AND g.Year = 5;

SELECT DISTINCT t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT DISTINCT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE s.DayOfWeek = 1
);

SELECT DISTINCT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT DISTINCT s.LectureRoomId
    FROM Schedules s
    WHERE s.DayOfWeek = 3 AND s.Week = 2 AND s.Class = 3
);

SELECT DISTINCT t.Name, t.Surname
FROM Teachers t
JOIN Faculties f ON f.DeanId = t.Id
WHERE f.Name = 'Computer Science'
AND t.Id NOT IN (
    SELECT DISTINCT c.TeacherId
    FROM Curators c
    JOIN GroupsCurators gc ON c.Id = gc.CuratorId
    JOIN Groups g ON gc.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    WHERE d.Name = 'Software Development'
);

SELECT DISTINCT Building FROM Faculties
UNION
SELECT DISTINCT Building FROM Departments
UNION
SELECT DISTINCT Building FROM LectureRooms;

SELECT t.Name, t.Surname
FROM Teachers t
LEFT JOIN Deans d ON t.Id = d.TeacherId
LEFT JOIN Heads h ON t.Id = h.TeacherId
LEFT JOIN Curators c ON t.Id = c.TeacherId
LEFT JOIN Assistants a ON t.Id = a.TeacherId
ORDER BY
    CASE
        WHEN d.Id IS NOT NULL THEN 1
        WHEN h.Id IS NOT NULL THEN 2
        WHEN c.Id IS NOT NULL THEN 3
        WHEN a.Id IS NOT NULL THEN 4
        ELSE 5
    END;

SELECT DISTINCT DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Name IN ('A311', 'A104');