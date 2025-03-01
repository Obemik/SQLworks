create database HomePets;
go
use HomePets;
go
create table PetOwners
(
    OwnerID int primary key,
    OwnerName varchar(50),
    OwnerAddress varchar(50),
    OwnerPhone varchar(50)
);
go
create table Pets
(
    PetID int primary key,
    PetName varchar(50),
    PetType varchar(50),
    PetBreed varchar(50),
    PetDOB date,
    OwnerID int foreign key references PetOwners(OwnerID)
);
go
create table PetAndOwner
(
    PetID int foreign key references Pets(PetID),
    OwnerID int foreign key references PetOwners(OwnerID),
    primary key(PetID, OwnerID)
);
go
insert into PetOwners values
(1, 'John', '123 Main St', '555-1234'),
(2, 'Jane', '456 Elm St', '555-5678'),
(3, 'Jim', '789 Oak St', '555-9012'),
(4, 'Jill', '101 Pine St', '555-3456'),
(5, 'Jack', '112 Cedar St', '555-7890');
go
insert into Pets values
(1, 'Fido', 'Dog', 'Poodle', '2005-01-01', 1),
(2, 'Fluffy', 'Cat', 'Siamese', '2006-02-02', 2),
(3, 'Spot', 'Dog', 'Dalmation', '2007-03-03', 3),
(4, 'Whiskers', 'Cat', 'Persian', '2008-04-04', 4),
(5, 'Rover', 'Dog', 'Beagle', '2009-05-05', 5);
go
insert into PetAndOwner values
(1, 3),
(2, 4),
(3, 5);
go
select * from PetOwners;
select * from Pets;
select * from PetAndOwner;
go
select OwnerName, PetName, PetType, PetBreed, PetDOB from PetOwners
join Pets on PetOwners.OwnerID = Pets.OwnerID;
go
select OwnerName, PetName, PetType, PetBreed, PetDOB  from PetOwners
full join PetAndOwner on PetOwners.OwnerID = PetAndOwner.OwnerID
full join Pets on PetAndOwner.PetID = Pets.PetID
group by OwnerName, PetName, PetType, PetBreed, PetDOB
having PetType = 'Dog';