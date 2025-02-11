create database HospitalDB;
go
use HospitalDB;
go
create table Doctor
(
    DoctorID int primary key identity(1,1),
    DoctorName varchar(50) check(DoctorName like '[A-Z]%') not null,
    DoctorSpeciality varchar(50) check(DoctorSpeciality like '[A-Z]%'),
    DoctorSalary money check(DoctorSalary > 0) default 3500,
);
go
create table CountryCode
(
    CountryCodeID int primary key identity(1,1),
    CountryCode varchar(50) check(CountryCode like '[0-9]%') not null,
    CountryName varchar(50) check(CountryName like '[A-Z]%') not null,
);
go
create table Patient
(
    PatientID int primary key identity(1,1),
    PatientName varchar(50) check(PatientName like '[A-Z]%') not null,
    PatientAge int check(PatientAge > 0 and PatientAge < 120) not null,
    PatientGender varchar(50),
    PatientAddress varchar(100) not null,
    CountryCodeID int foreign key references CountryCode(CountryCodeID),
    PatientPhone varchar(50) check(PatientPhone like '[0-9]%') not null,
    PatientEmail varchar(50) check(PatientEmail like '%@%') not null,
);
go
create table Appointment
(
    AppointmentID int primary key identity(1,1),
    AppointmentDate date not null default getdate(),
    AppointmentTime time not null,
    DoctorID int foreign key references Doctor(DoctorID) check(DoctorID > 0),
    PatientID int foreign key references Patient(PatientID) check(PatientID > 0),
);
go
create table Prescription
(
    PrescriptionID int primary key identity(1,1),
    PrescriptionDate date not null default getdate(),
    PrescriptionTime time not null,
    DoctorID int foreign key references Doctor(DoctorID) check(DoctorID > 0),
    PatientID int foreign key references Patient(PatientID) check(PatientID > 0),
    PrescriptionDetails varchar(100) not null,
);
go
insert into Doctor(DoctorName, DoctorSpeciality, DoctorSalary) values
('Dr. John', 'Cardiologist', 5000),
('Dr. Smith', 'Dermatologist', 4000),
('Dr. Alex', 'Gynecologist', 4500),
('Dr. David', 'Neurologist', 5500),
('Dr. Michael', 'Oncologist', 6000);
go
insert into CountryCode(CountryCode, CountryName) values
('1', 'USA'),
('44', 'UK'),
('91', 'India'),
('61', 'Australia'),
('81', 'Japan');
go
insert into Patient (PatientName, PatientAge, PatientGender, PatientAddress, CountryCodeID, PatientPhone, PatientEmail) values
('Alice', 12, 'Female', 'Main str. 123', 1, '1234567890', 'alice@example.com'),
('Bob', 24, 'Male', 'Elm str. 23', 2, '2345678901', 'bob.example@gmail.com'),                                                                                                  ('Charlie', 30, 'Male', '789 Pine St', 3, '3456789012', 'charlie@example.com'),
('Diana', 45, 'Female', 'Maple str. 26', 4, '4567890123', 'diana@example.com'),
('Eve', 29, 'Female', 'Oak St. 56', 5, '5678901234', 'eve@example.com'),
('Frank', 35, 'Male', 'Birch St. 64', 1, '6789012345', 'frank@example.com'),
('Grace', 50, 'Female', 'Cedar St. 545A', 2, '7890123456', 'grace@example.com');
go
insert into Appointment(AppointmentDate, AppointmentTime, DoctorID, PatientID) values
('2021-10-01', '10:00:00', 1, 1),
('2021-10-02', '11:00:00', 2, 2),
('2021-10-03', '12:00:00', 3, 3),
('2021-10-04', '13:00:00', 4, 4),
('2021-10-05', '14:00:00', 5, 5);
go
insert into Prescription(PrescriptionDate, PrescriptionTime, DoctorID, PatientID, PrescriptionDetails) values
('2021-10-01', '10:00:00', 1, 1, 'Prescription for Alice'),
('2021-10-02', '11:00:00', 2, 2, 'Prescription for Bob'),
('2021-10-03', '12:00:00', 3, 3, 'Prescription for Charlie'),
('2021-10-04', '13:00:00', 4, 4, 'Prescription for Diana'),
('2021-10-05', '14:00:00', 5, 5, 'Prescription for Eve');
go
select * from Doctor;
select * from CountryCode;
select * from Patient;
select * from Appointment;
select * from Prescription;

select * from Doctor
join Appointment A on Doctor.DoctorID = A.DoctorID
join Patient P on A.PatientID = P.PatientID
join Prescription Pr on A.PatientID = Pr.PatientID
join CountryCode C on P.CountryCodeID = C.CountryCodeID;

select avg(DoctorSalary) as TotalSalary  from Doctor;
select count(*) as TotalDoctors from Doctor
join Appointment as A on Doctor.DoctorID = A.DoctorID
join Patient as P on A.PatientID = P.PatientID
where P.PatientAge > 30;

drop database HospitalDB;