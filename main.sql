create database Academy2;
go

use Academy2;
go

create table faculties
(
    id int primary key identity(1,1),
    dean nvarchar(max) not null,
    name nvarchar(100) not null unique
);
go

create table departments
(
    id int primary key identity(1,1),
    financing money not null check(financing >= 0),
    name nvarchar(100) not null unique
);
go

create table teachers
(
    id int primary key identity(1,1),
    employmentdate date not null check(employmentdate >= '1990-01-01'),
    isassistant bit not null default 0,
    isprofessor bit not null default 0,
    name nvarchar(max) not null,
    position nvarchar(max) not null,
    premium money not null check(premium >= 0),
    salary money not null check(salary > 0),
    surname nvarchar(max) not null
);
go

create table groups
(
    id int primary key identity(1,1),
    name nvarchar(10) not null unique,
    rating int not null check(rating between 0 and 5),
    year int not null check(year between 1 and 5)
);
go

insert into faculties (dean, name)
values
('dr. smith', 'computer science'),
('dr. brown', 'mathematics'),
('dr. white', 'physics');
go

insert into departments (financing, name)
values
(20000, 'software development'),
(15000, 'mathematical sciences'),
(25000, 'physics research');
go

insert into teachers (employmentdate, isassistant, isprofessor, name, position, premium, salary, surname)
values
('1998-05-10', 1, 0, 'john', 'assistant', 500, 1000, 'doe'),
('2005-08-22', 0, 1, 'jane', 'professor', 1000, 2500, 'smith'),
('2010-11-15', 1, 0, 'jim', 'assistant', 200, 1200, 'brown');
go

insert into groups (name, rating, year)
values
('group a', 4, 3),
('group b', 3, 5),
('group c', 2, 4);
go

select financing, name, id
from departments;
go

select name as "group name", rating as "group rating"
from groups;
go

select surname,
       (salary / premium) * 100 as "salary to premium %",
       (salary / (salary + premium)) * 100 as "salary to total %"
from teachers;
go

select 'the dean of faculty ' + name + ' is ' + dean + '.' as facultyinfo
from faculties;
go

select surname
from teachers
where isprofessor = 1 and salary > 1050;
go

select name
from departments
where financing < 11000 or financing > 25000;
go

select name
from faculties
where name != 'computer science';
go

select surname, position
from teachers
where isprofessor = 0;
go

select surname, position, salary, premium
from teachers
where isassistant = 1 and premium between 160 and 550;
go

select surname, salary
from teachers
where isassistant = 1;
go

select surname, position
from teachers
where employmentdate < '2000-01-01';
go

select name as "name of department"
from departments
where name < 'software development'
order by name;
go

select surname
from teachers
where isassistant = 1 and (salary + premium) <= 1200;
go

select name
from groups
where year = 5 and rating between 2 and 4;
go

select surname
from teachers
where isassistant = 1 and (salary < 550 or premium < 200);
go
