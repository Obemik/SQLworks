create database Hospital;
go
use Hospital;
go

create table Departments
(
    ID int identity(1,1) primary key,
    Building int not null check (Building between 1 and 5),
    Financing money not null check (Financing >= 0) default 0,
    Name nvarchar(100) not null unique check (len(Name) > 0)
);
go

create table Diseases
(
    ID int identity(1,1) primary key,
    Name nvarchar(100) not null unique check (len(Name) > 0),
    Severity int not null check (Severity >= 1) default 1
);
go

create table Doctors
(
    ID int identity(1,1) primary key,
    Name nvarchar(max) not null check (len(Name) > 0),
    Surname nvarchar(max) not null check (len(Surname) > 0),
    Phone char(10) not null,
    Salary money not null check (Salary > 0)
);
go

create table Examinations
(
    ID int identity(1,1) primary key,
    Name nvarchar(100) not null unique check (len(Name) > 0),
    DayOfWeek int not null check (DayOfWeek between 1 and 7),
    StartTime time not null check (StartTime between '08:00' and '18:00'),
    EndTime time not null,
    constraint CHK_Time check (EndTime > StartTime)
);
go

insert into Departments values
(1, 50000, 'Cardiology'),
(2, 75000, 'Neurology'),
(3, 60000, 'Orthopedics');
go

insert into Diseases values
('Heart Attack', 5),
('Migraine', 2),
('Fracture', 3);
go

insert into Doctors values
('John', 'Doe', '1234567890', 5000),
('Alice', 'Smith', '0987654321', 4500),
('Robert', 'Brown', '1122334455', 4800);
go

insert into Examinations values
('ECG', 1, '08:30', '09:00'),
('MRI', 3, '10:00', '11:30'),
('X-ray', 5, '14:00', '14:30');
go

select * from Departments;
select * from Diseases;
select * from Doctors;
select * from Examinations;
go
