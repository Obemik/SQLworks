create database Airport;
go
use Airport;
go

create table Cities
(
    Id int primary key identity(1,1) not null,
    Name nvarchar(100) not null unique
);
go

create table Airplanes
(
    Id int primary key identity(1,1) not null,
    Model nvarchar(100) not null unique,
    BusinessCapacity int not null,
    EconomyCapacity int not null
);
go

create table Flights
(
    Id int primary key identity(1, 1) not null,
    FlightNumber nvarchar(100) not null unique,
    DepartureTime datetime not null,
    ArrivalTime datetime not null,
    DepartureCityId int not null,
    ArrivalCityId int not null,
    Duration int not null,
    AirplaneId int not null,

    constraint DepartureCityIdFK foreign key (DepartureCityId) references Cities(Id),
    constraint ArrivalCityIdFK foreign key (ArrivalCityId) references Cities(Id),
    constraint AirplaneIdFK foreign key (AirplaneId) references Airplanes(Id)
);
go

create table Passengers
(
    Id int primary key identity(1, 1) not null,
    FirstName nvarchar(100) not null,
    LastName nvarchar(100) not null,
    PassportNumber nvarchar(100) not null unique
);
go

create table Tickets
(
    Id int primary key identity(1, 1) not null,
    FlightId int not null,
    PassengerId int not null,
    SeatClass varchar(10) NOT NULL CHECK (SeatClass IN ('business', 'economy')),
    Price money not null,
    IsSold bit not null default 0,

    constraint FlightIdFK foreign key (FlightId) references Flights(Id),
    constraint PassengerIdFK foreign key (PassengerId) references Passengers(Id)
);
go

CREATE TRIGGER TrgOnInsertTickets
ON Tickets
FOR INSERT
AS
BEGIN
    DECLARE @FlightId INT, @SeatClass VARCHAR(10), @IsSold bit;

    SELECT @FlightId = FlightId, @SeatClass = SeatClass, @IsSold = IsSold FROM INSERTED;

    IF @IsSold = 1
    BEGIN
        IF @SeatClass = 'economy'
        BEGIN
            UPDATE A
            SET EconomyCapacity = EconomyCapacity - 1
            FROM Airplanes A
            JOIN Flights F ON A.Id = F.AirplaneId
            WHERE F.Id = @FlightId;
        END
        ELSE IF @SeatClass = 'business'
        BEGIN
            UPDATE A
            SET BusinessCapacity = BusinessCapacity - 1
            FROM Airplanes A
            JOIN Flights F ON A.Id = F.AirplaneId
            WHERE F.Id = @FlightId;
        END
    END
END;
go

insert into Cities (Name) values
    ('New York'),
    ('Prague'),
    ('Paris'),
    ('London'),
    ('Tokyo'),
    ('Beijing'),
    ('Sydney'),
    ('Los Angeles'),
    ('Toronto'),
    ('Berlin');
go

insert into Airplanes (Model, BusinessCapacity, EconomyCapacity) values
    ('Boeing 747', 50, 300),
    ('Airbus A380', 100, 500),
    ('Boeing 777', 75, 400),
    ('Airbus A320', 25, 150),
    ('Boeing 737', 30, 200),
    ('Airbus A330', 40, 250),
    ('Boeing 787', 60, 350),
    ('Airbus A350', 50, 300),
    ('Boeing 767', 50, 300),
    ('Airbus A340', 50, 300);
go

insert into Flights (FlightNumber, DepartureTime, ArrivalTime, DepartureCityId, ArrivalCityId, Duration, AirplaneId) values
    ('NY-PR-001', '2025-01-05 08:00:00', '2025-01-05 12:00:00', 1, 2, 240, 1),
    ('NY-PA-002', '2025-02-09 10:00:00', '2025-02-09 14:00:00', 1, 3, 240, 2),
    ('NY-LO-003', '2025-01-04 12:00:00', '2025-01-04 16:00:00', 1, 4, 240, 3),
    ('NY-TO-004', '2025-01-14 14:00:00', '2025-01-14 18:00:00', 1, 9, 240, 4),
    ('NY-TK-005', '2025-02-20 16:00:00', '2025-02-20 20:00:00', 1, 5, 240, 5),
    ('NY-BJ-006', '2025-02-13 18:00:00', '2025-02-13 22:00:00', 1, 6, 240, 6),
    ('NY-SY-007', '2025-01-11 20:00:00', '2025-01-12 00:00:00', 1, 7, 240, 7),
    ('NY-LA-008', '2025-01-11 22:00:00', '2025-01-12 02:00:00', 1, 8, 240, 8),
    ('PR-PA-009', '2025-03-14 08:00:00', '2025-03-14 12:00:00', 2, 3, 240, 9),
    ('PR-LO-010', '2025-03-14 10:00:00', '2025-03-14 14:00:00', 2, 4, 240, 10),
    ('PR-TO-011', '2025-01-20 12:00:00', '2025-01-20 16:00:00', 2, 9, 240, 1),
    ('PR-TK-012', '2025-01-09 14:00:00', '2025-01-09 18:00:00', 2, 5, 240, 2),
    ('PR-BJ-013', '2025-01-03 16:00:00', '2025-01-03 20:00:00', 2, 6, 240, 3),
    ('PR-SY-014', '2025-02-05 18:00:00', '2025-02-05 22:00:00', 2, 7, 240, 4),
    ('PR-LA-015', '2025-02-05 20:00:00', '2025-02-06 00:00:00', 2, 8, 240, 5),
    ('PR-TO-016', '2025-03-15 22:00:00', '2025-03-16 02:00:00', 2, 9, 240, 6),
    ('PA-LO-017', '2025-01-20 08:00:00', '2025-01-20 12:00:00', 3, 4, 240, 7),
    ('PA-TO-018', '2025-02-19 10:00:00', '2025-02-19 14:00:00', 3, 9, 240, 8),
    ('PA-TK-019', '2025-01-19 12:00:00', '2025-01-19 16:00:00', 3, 5, 240, 9),
    ('PA-BJ-020', '2025-02-16 14:00:00', '2025-02-16 18:00:00', 3, 6, 240, 10);
go

insert into Passengers (FirstName, LastName, PassportNumber) values
    ('John', 'Doe', '1234567890'),
    ('Jane', 'Doe', '0987654321'),
    ('Alice', 'Smith', '1357924680'),
    ('Bob', 'Smith', '8642097531'),
    ('Charlie', 'Brown', '2468013579'),
    ('Daisy', 'Johnson', '9753186240'),
    ('Eve', 'White', '5318642970'),
    ('Frank', 'Black', '7082941536'),
    ('Grace', 'Green', '1594837260'),
    ('Henry', 'Blue', '6302974851'),
    ('Ivy', 'Red', '2947536180'),
    ('Jack', 'Orange', '4863729150'),
    ('Kelly', 'Yellow', '7531806429'),
    ('Larry', 'Purple', '2974851306'),
    ('Molly', 'Pink', '3729154860'),
    ('Nancy', 'Violet', '1806429753'),
    ('Oscar', 'Gold', '4851306729'),
    ('Patty', 'Silver', '9154863720'),
    ('Quincy', 'Bronze', '0642975183'),
    ('Roger', 'Copper', '1306729458');
go

insert into Tickets (FlightId, PassengerId, SeatClass, Price, IsSold) values
    (1, 1, 'business', 1000, 1),
    (1, 2, 'economy', 500, 1),
    (2, 3, 'business', 1000, 1),
    (2, 4, 'economy', 500, 1),
    (3, 5, 'business', 1000, 1),
    (3, 6, 'economy', 500, 1),
    (4, 7, 'business', 1000, 1),
    (4, 8, 'economy', 500, 1),
    (5, 9, 'business', 1000, 1),
    (5, 10, 'economy', 500, 1),
    (6, 11, 'business', 1000, 1),
    (6, 12, 'economy', 500, 1),
    (7, 13, 'business', 1000, 1),
    (7, 14, 'economy', 500, 1),
    (8, 15, 'business', 1000, 1),
    (8, 16, 'economy', 500, 1),
    (9, 17, 'business', 1000, 1),
    (9, 18, 'economy', 500, 1),
    (10, 19, 'business', 1000, 1),
    (10, 20, 'economy', 500, 1),
    (11, 1, 'business', 1000, 1),
    (11, 2, 'economy', 500, 1),
    (12, 3, 'business', 1000, 1),
    (12, 4, 'economy', 500, 0),
    (13, 5, 'business', 1000, 0),
    (13, 6, 'economy', 500, 1),
    (14, 7, 'business', 1000, 0),
    (14, 8, 'economy', 500, 1),
    (15, 9, 'business', 1000, 0),
    (15, 10, 'economy', 500, 0),
    (16, 11, 'business', 1000, 1),
    (16, 12, 'economy', 500, 0),
    (17, 13, 'business', 1000, 0),
    (17, 14, 'economy', 500, 0),
    (18, 15, 'business', 1000, 1),
    (18, 16, 'economy', 500, 1),
    (19, 17, 'business', 1000, 0),
    (19, 18, 'economy', 500, 0),
    (20, 19, 'business', 1000, 0),
    (20, 20, 'economy', 500, 1);
go

select
    F.FlightNumber as FlightNumber,
    F.DepartureTime as DepartureTime,
    F.ArrivalTime as ArrivalTime,
    C.Name as ArrivalCity
from Flights F
left join Cities C on F.ArrivalCityId = C.Id
where C.Name = 'Paris'
order by F.DepartureTime;
go

select top 1
    F.FlightNumber as FlightNumber,
    F.DepartureTime as DepartureTime,
    F.ArrivalTime as ArrivalTime,
    CD.Name as DepartureCity,
    CA.Name as ArrivalCity,
    F.Duration as Duration,
    A.Model as AirplaneModel
from Flights F
left join Cities CD on F.DepartureCityId = CD.Id
left join Cities CA on F.ArrivalCityId = CA.Id
left join Airplanes A on F.AirplaneId = A.Id
order by datediff(hour, F.DepartureTime, F.ArrivalTime) desc;
go

select
    F.FlightNumber as FlightNumber,
    F.DepartureTime as DepartureTime,
    F.ArrivalTime as ArrivalTime,
    datediff(hour, F.DepartureTime, F.ArrivalTime) as FlightTime,
    CD.Name as DepartureCity,
    CA.Name as ArrivalCity,
    F.Duration as Duration,
    A.Model as AirplaneModel
from Flights F
left join Cities CD on F.DepartureCityId = CD.Id
left join Cities CA on F.ArrivalCityId = CA.Id
left join Airplanes A on F.AirplaneId = A.Id
where datediff(hour, F.DepartureTime, F.ArrivalTime) > 2;
go

select
    C.Name as City,
    count(distinct F.Id) as FlightsCount
from Flights F
join Cities C on F.ArrivalCityId = C.Id
group by C.Name;
go

select top 1
    C.Name as City,
    count(distinct F.Id) as FlightsCount
from Flights F
join Cities C on F.ArrivalCityId = C.Id
group by C.Name
order by FlightsCount desc;
go

select
    C.Name as City,
    count(distinct F.Id) as FlightsCount,
    (select count(distinct F2.Id)
     from Flights F2
     where month(F2.DepartureTime) = 1 and year(F2.DepartureTime) = 2025) as FlightsCountInMonth
from Flights F
join Cities C on F.ArrivalCityId = C.Id
group by C.Name;
go

select
    F.FlightNumber as FlightNumber,
    F.DepartureTime as DepartureTime,
    F.ArrivalTime as ArrivalTime,
    CD.Name as DepartureCity,
    CA.Name as ArrivalCity,
    A.BusinessCapacity - (select count(*) from Tickets T where T.FlightId = F.Id and T.SeatClass = 'business' and T.IsSold = 1) as BusinessSeatsAvailable
from Flights F
left join Cities CD on F.DepartureCityId = CD.Id
left join Cities CA on F.ArrivalCityId = CA.Id
join Airplanes A on F.AirplaneId = A.Id
where convert(date, F.DepartureTime) = convert(date, getdate())
  and A.BusinessCapacity - (select count(*) from Tickets T where T.FlightId = F.Id and T.SeatClass = 'business' and T.IsSold = 1) > 0;
go

select
    count(T.Id) as TicketsCount,
    sum(T.Price) as TotalIncome
from Tickets T
left join Flights F on T.FlightId = F.Id
where cast(F.DepartureTime as date) = '2025-02-05' and T.IsSold = 1;
go

select
    F.FlightNumber as FlightNumber,
    count(T.Id) as TicketsCount
from Tickets T
left join Flights F on T.FlightId = F.Id
where cast(F.DepartureTime as date) = '2025-02-05' and T.IsSold = 1
group by F.FlightNumber, F.DepartureTime, F.ArrivalTime;
go

select
    F.FlightNumber as FlightNumber,
    C.Name as ArrivalCity
from Flights F
left join Cities C on F.ArrivalCityId = C.Id;
go