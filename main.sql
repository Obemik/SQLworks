create database Academy;
go
use Academy;
go

create table Groups
(
    Id int identity(1,1) primary key,
    Name nvarchar(10) not null unique check (len(Name) > 0),
    Rating int not null check (Rating between 0 and 5),
    Year int not null check (Year between 1 and 5)
);
go

create table Departments
(
    Id int identity(1,1) primary key,
    Financing money not null check (Financing >= 0) default 0,
    Name nvarchar(100) not null unique check (len(Name) > 0)
);
go

create table Faculties
(
    Id int identity(1,1) primary key,
    Name nvarchar(100) not null unique check (len(Name) > 0)
);
go

create table Teachers
(
    Id int identity(1,1) primary key,
    EmploymentDate date not null check (EmploymentDate >= '1990-01-01'),
    Name nvarchar(max) not null check (len(Name) > 0),
    Surname nvarchar(max) not null check (len(Surname) > 0),
    Premium money not null check (Premium >= 0) default 0,
    Salary money not null check (Salary > 0)
);
go

insert into Groups values
('CS101', 4, 1),
('MATH202', 3, 2),
('BIO303', 5, 3);
go

insert into Departments values
(100000, 'Computer Science'),
(150000, 'Mathematics'),
(120000, 'Biology');
go

insert into Faculties values
('Engineering'),
('Natural Sciences');
go

insert into Teachers values
('2005-09-01', 'John', 'Doe', 500, 3000),
('2010-08-15', 'Jane', 'Smith', 300, 2800),
('2018-02-20', 'Alice', 'Brown', 200, 2500);
go

select * from Groups;
select * from Departments;
select * from Faculties;
select * from Teachers;
go
