--TABLES
DROP TABLE Account;
DROP TABLE Trip;  
DROP TABLE Booking;
DROP TABLE Flight; 
DROP TABLE Class;
DROP TABLE Airlines; 
DROP TABLE Train; 
DROP TABLE Bus;
DROP TABLE CarUse;
DROP TABLE Private;
DROP TABLE Car_hailing;
DROP TABLE Delivery; 
DROP TABLE Carbon; 
DROP TABLE CarbonTotal; 

DROP SEQUENCE account_seq; 
DROP SEQUENCE trip_seq; 
DROP SEQUENCE booking_seq; 
DROP SEQUENCE class_seq; 
DROP SEQUENCE airline_seq; 
DROP SEQUENCE bus_seq; 
DROP SEQUENCE car_seq; 

DROP PROCEDURE add_account; 
DROP PROCEDURE add_flight; 
DROP PROCEDURE add_bus; 
DROP PROCEDURE add_private_car; 

CREATE TABLE Account (
	Id DECIMAL(12) NOT NULL PRIMARY KEY, 
	FirstName VARCHAR(24) NOT NULL, 
	LastName VARCHAR(24) NOT NULL, 
	Gender VARCHAR(12) NOT NULL, 
	Career VARCHAR(24), 
	Since DATE, 
	CarbonTotal DECIMAL); 

CREATE TABLE Trip (
	TripId DECIMAL NOT NULL PRIMARY KEY, 
	Id DECIMAL(12) FOREIGN KEY REFERENCES Account (Id), 
	Date DATE, 
	Departure VARCHAR(24), 
	Destination VARCHAR(24), 
	Miles DECIMAL); 

CREATE TABLE Booking (
	BookingId DECIMAL NOT NULL PRIMARY KEY, 
	TripId DECIMAL FOREIGN KEY REFERENCES Trip (TripId), 
	TransportId DECIMAL); 

CREATE TABLE Flight (
	BookingId DECIMAL NOT NULL PRIMARY KEY, 
	ClassId DECIMAL(24), 
	AirlineId DECIMAL(24)); 

CREATE TABLE Class (
	ClassId DECIMAL(24) PRIMARY KEY, 
	Classname VARCHAR(24)); 

CREATE TABLE Airlines (
	AirlineId DECIMAL(24) PRIMARY KEY, 
	Airline VARCHAR(24)); 

CREATE TABLE Train (
	BookingId DECIMAL NOT NULL PRIMARY KEY);

CREATE TABLE Bus (
	BusId DECIMAL NOT NULL PRIMARY KEY, 
	TripId DECIMAL FOREIGN KEY REFERENCES Trip (TripId), 
	TransportId DECIMAL); 

CREATE TABLE CarUse (
	CarUseId DECIMAL NOT NULL PRIMARY KEY, 
	TripId DECIMAL FOREIGN KEY REFERENCES Trip (TripId), 
	TransportId DECIMAL); 

CREATE TABLE Private (
	CarUseId DECIMAL NOT NULL PRIMARY KEY); 

CREATE TABLE Car_hailing (
	CarUseId DECIMAL NOT NULL PRIMARY KEY, 
	Share DECIMAL(12)); 

CREATE TABLE Delivery (
	CarUseId DECIMAL NOT NULL PRIMARY KEY, 
	DeliverType VARCHAR(24)); 

CREATE TABLE Carbon (
	TransportId DECIMAL(12) PRIMARY KEY, 
	TransportType VARCHAR(24), 
	GasEmission DECIMAL); 

INSERT INTO Carbon (TransportId, TransportType, GasEmission)
VALUES (1, 'Flight', 150), 
		(2, 'Bus', 105), 
		(31, 'Private Car', 192),
		(32, 'Car-hailing', 192), 
		(33, 'Delivery', 192), 
		(4, 'Train', 40); 
SELECT * FROM Carbon; 


--SEQUENCES

CREATE SEQUENCE account_seq START WITH 1; 
CREATE SEQUENCE trip_seq START WITH 1;
CREATE SEQUENCE booking_seq START WITH 1;
CREATE SEQUENCE class_seq START WITH 1;
CREATE SEQUENCE airline_seq START WITH 1;
CREATE SEQUENCE bus_seq START WITH 1;
CREATE SEQUENCE car_seq START WITH 1;



--PROCEDURE
--PROCEDURE Account

CREATE PROCEDURE add_account
	@FirstName VARCHAR(24), 
	@LastName VARCHAR(24), 
	@Gender VARCHAR(12), 
	@Career VARCHAR(24), 
	@Date DATE
AS 
BEGIN
	INSERT INTO Account (Id, FirstName, LastName, Gender, Career, Since, CarbonTotal)
	VALUES (NEXT VALUE FOR account_seq, @FirstName, @LastName, @Gender, @Career, @Date, 0); 
END; 
GO
BEGIN TRANSACTION add_account; 
EXECUTE add_account 'Jennifer', 'Johnson', 'Female', 'Doctor', '12/20/2020';
EXECUTE add_account 'Natalie', 'Robinson', 'Male', 'Fireman', '12/20/2020';
EXECUTE add_account 'John', 'Ferguson', 'Male', 'Teacher', '12/29/2020';
EXECUTE add_account 'Samuel', 'Patterson', 'Male', 'Baker', '12/31/2020';
EXECUTE add_account 'Jasmine', 'James', 'Female', 'Artist', '01/06/2021';
EXECUTE add_account 'Michelle', 'Stella', 'Female', 'Business analyst', '01/07/2021';
EXECUTE add_account 'Patricia', 'Hamilton', 'Female', 'Entrepreneur', '01/18/2021';
EXECUTE add_account 'Elijah', 'Fisher', 'Male', 'Designer', '02/01/2021';
EXECUTE add_account 'Justin', 'Wright', 'Male', 'Teacher', '02/14/2021';
EXECUTE add_account 'Paula', 'Reyes', 'Female', 'Teacher', '02/14/2021';
COMMIT TRANSACTION; 
SELECT * FROM Account; 


--PROCEDURE flight
CREATE PROCEDURE add_flight
	@FirstName VARCHAR(24), 
	@LastName VARCHAR(24), 
	@Date DATE, 
	@Departure VARCHAR(24), 
	@Destination VARCHAR(24),
	@Miles DECIMAL, 
	@Class VARCHAR(24), 
	@Airline VARCHAR(24)
AS 
BEGIN
	DECLARE @v_Id DECIMAL(12);
	DECLARE @trip_seq INT = NEXT VALUE FOR trip_seq;
	DECLARE @booking_seq INT = NEXT VALUE FOR booking_seq;

	SELECT @v_Id = Id
	FROM Account
	WHERE FirstName = @FirstName and LastName = @LastName;

	INSERT INTO Trip (TripId, Id, Date, Departure, Destination, Miles)
	VALUES (@trip_seq, @v_Id, @Date, @Departure, @Destination, @Miles);

	INSERT INTO Booking (BookingId, TripId, TransportId)
	VALUES (@booking_seq, @trip_seq, 1); 

	IF NOT EXISTS (SELECT * FROM Class
					WHERE Classname = @Class)
	BEGIN
		DECLARE @class_seq INT = NEXT VALUE FOR class_seq;
		INSERT INTO Class (ClassId, Classname)
		VALUES (@class_seq, @Class)
	END

	IF NOT EXISTS (SELECT * FROM Airlines 
                   WHERE Airline = @Airline)
	BEGIN
		DECLARE @airline_seq INT = NEXT VALUE FOR airline_seq;
		INSERT INTO Airlines (AirlineId, Airline)
		VALUES (@airline_seq, @Airline)
	END

	DECLARE @class_seq_v DECIMAL(12) = (SELECT ClassId FROM Class WHERE Classname = @Class);
	DECLARE @airline_seq_v DECIMAL(12) = (SELECT AirlineId FROM Airlines WHERE Airline = @Airline)
	INSERT INTO Flight (BookingId, ClassId, AirlineId)
	VALUES (@booking_seq, @class_seq_v, @airline_seq_v)

	--insert into account table
END; 
GO
BEGIN TRANSACTION add_flight; 
EXECUTE add_flight 'Jennifer', 'Johnson', '01/20/2021', 'Boston', 'Chicago', 867, 'economy', 'JetBlue';
EXECUTE add_flight 'Jennifer', 'Johnson', '01/29/2021', 'Chicago', 'Boston', 867, 'economy', 'JetBlue';
EXECUTE add_flight 'Natalie', 'Robinson', '01/03/2021', 'New York', 'Austin', 1521, 'first', 'Spirit';
EXECUTE add_flight 'Michelle', 'Stella', '02/25/2021', 'Washington, D.C.', 'Los Angeles', 2311, 'economy', 'Frontier';
EXECUTE add_flight 'Michelle', 'Stella', '03/03/2021', 'Los Angeles', 'Portland', 834, 'economy', 'Frontier';
EXECUTE add_flight 'Patricia', 'Hamilton', '02/20/2021', 'Las Vegas', 'Chicago', 1521, 'economy', 'JetBlue';
EXECUTE add_flight 'Elijah', 'Fisher', '02/16/2021', 'Boston', 'Chicago', 867, 'economy', 'United';
EXECUTE add_flight 'Michelle', 'Stella', '03/12/2021', 'Portland', 'Washington, D.C.', 2350, 'economy', 'Frontier';
EXECUTE add_flight 'Elijah', 'Fisher', '01/14/2021', 'Miami', 'Tulsa', 1168, 'economy', 'United';
EXECUTE add_flight 'Paula', 'Reyes', '01/20/2021', 'Phoenix', 'Chicago', 1444, 'economy', 'JetBlue';

COMMIT TRANSACTION; 

SELECT * FROM Trip; 
SELECT * FROM Booking; 
SELECT * FROM Flight; 
SELECT * FROM Class; 
SELECT * FROM Airlines; 


--PROCEDURE bus
CREATE PROCEDURE add_bus
	@FirstName VARCHAR(24), 
	@LastName VARCHAR(24), 
	@Date DATE, 
	@Departure VARCHAR(24), 
	@Destination VARCHAR(24),
	@Miles DECIMAL
AS 
BEGIN
	DECLARE @v_Id DECIMAL(12);
	DECLARE @trip_seq INT = NEXT VALUE FOR trip_seq;
	DECLARE @bus_seq INT = NEXT VALUE FOR bus_seq;

	SELECT @v_Id = Id
	FROM Account
	WHERE FirstName = @FirstName and LastName = @LastName;

	INSERT INTO Trip (TripId, Id, Date, Departure, Destination, Miles)
	VALUES (@trip_seq, @v_Id, @Date, @Departure, @Destination, @Miles);

	INSERT INTO Bus (BusId, TripId, TransportId)
	VALUES (@bus_seq, @trip_seq, 2); 

END; 
GO
BEGIN TRANSACTION add_bus; 
EXECUTE add_bus 'John', 'Ferguson', '01/19/2021', 'Chicago-bus1', 'Chicago-bus10', 13;
EXECUTE add_bus 'John', 'Ferguson', '01/23/2021', 'Chicago-bus4', 'Chicago-bus7', 9;
EXECUTE add_bus 'Samuel', 'Patterson', '01/06/2021', 'Miami-bus2', 'Miami-bus9', 12;
EXECUTE add_bus 'Jasmine', 'James', '02/14/2021', 'Portland-bus1', 'Portland-bus2', 4;
EXECUTE add_bus 'Jasmine', 'James', '02/22/2021', 'Portland-bus13', 'Portland-bus2', 15;
EXECUTE add_bus 'Samuel', 'Patterson', '01/28/2021', 'Chicago-bus1', 'Chicago-bus7', 7;
EXECUTE add_bus 'Patricia', 'Hamilton', '02/09/2021', 'Phoenix-bus12', 'Phoenix-bus6', 9;
EXECUTE add_bus 'Patricia', 'Hamilton', '03/02/2021', 'Miami-bus9', 'Miami-bus2', 8;
EXECUTE add_bus 'Elijah', 'Fisher', '01/27/2021', 'Chicago-bus5', 'Austin-bus11', 9;
EXECUTE add_bus 'Jasmine', 'James', '03/06/2021', 'Washington, D.C.-bus4', 'Washington, D.C.-bus9', 6;
COMMIT TRANSACTION; 

SELECT * FROM Trip; 
SELECT * FROM Bus; 

--PROCEDURE car use
CREATE PROCEDURE add_private_car
	@FirstName VARCHAR(24), 
	@LastName VARCHAR(24), 
	@Date DATE, 
	@Departure VARCHAR(24), 
	@Destination VARCHAR(24),
	@Miles DECIMAL
AS 
BEGIN
	DECLARE @v_Id DECIMAL(12);
	DECLARE @trip_seq INT = NEXT VALUE FOR trip_seq;
	DECLARE @car_seq INT = NEXT VALUE FOR car_seq;

	SELECT @v_Id = Id
	FROM Account
	WHERE FirstName = @FirstName and LastName = @LastName;

	INSERT INTO Trip (TripId, Id, Date, Departure, Destination, Miles)
	VALUES (@trip_seq, @v_Id, @Date, @Departure, @Destination, @Miles);

	INSERT INTO CarUse (CarUseId, TripId, TransportId)
	VALUES (@car_seq, @trip_seq, 31); 

	INSERT INTO Private (CarUseId)
	VALUES (@car_seq); 

END; 
GO
BEGIN TRANSACTION add_private_car; 
EXECUTE add_private_car 'Jennifer', 'Johnson', '01/22/2021', 'Miami-area1', 'Miami-area2', 37;
EXECUTE add_private_car 'Natalie', 'Robinson', '01/13/2021', 'Washington, D.C.-area1', 'Washington, D.C.-area2', 39;
EXECUTE add_private_car 'Natalie', 'Robinson', '01/28/2021', 'Washington, D.C.-area1', 'New York-area2', 178;
EXECUTE add_private_car 'John', 'Ferguson', '01/06/2021', 'Portland-area1', 'Chicago-area2', 258;
EXECUTE add_private_car 'John', 'Ferguson', '02/09/2021', 'Savannah-area1', 'Columbia-area2', 182;
EXECUTE add_private_car 'Natalie', 'Robinson', '02/23/2021', 'Chicago-area1', 'Chicago-area2', 44;
EXECUTE add_private_car 'Paula', 'Reyes', '01/25/2021', 'New York-area1', 'Portland-area2', 365;
EXECUTE add_private_car 'Paula', 'Reyes', '02/02/2021', 'Orlando-area1', 'Savannah-area2', 276;
EXECUTE add_private_car 'Elijah', 'Fisher', '01/31/2021', 'Columbia-area1', 'Chicago-area2', 143;
EXECUTE add_private_car 'Elijah', 'Fisher', '02/23/2021', 'Topeka-area1', 'New York-area2', 186;

COMMIT TRANSACTION; 

SELECT * FROM Trip; 
SELECT * FROM CarUse;
SELECT * FROM Private; 

--question
--carbon emission
CREATE OR ALTER VIEW individual_total_carbon
AS
SELECT FirstName, LastName, SUM(Miles * GasEmission) carbon_emission
FROM Trip t JOIN  
	(SELECT c.TransportId, TripId
	FROM Carbon c 
	INNER JOIN Booking b ON c.TransportId = b.TransportId
	UNION ALL
	SELECT c.TransportId, TripId
	FROM Carbon c 
	INNER JOIN Bus bu ON c.TransportId = bu.TransportId
	UNION ALL
	SELECT c.TransportId, TripId
	FROM Carbon c 
	INNER JOIN CarUse cu ON c.TransportId = cu.TransportId) tb
	ON t.TripId = tb.TripId
LEFT JOIN Account a ON a.Id = t.Id
LEFT JOIN Carbon c ON tb.TransportId = c.TransportId
GROUP BY FirstName, LastName; 

SELECT * FROM individual_total_carbon
ORDER BY carbon_emission DESC; 


DROP TABLE total_carbon; 
SELECT * INTO total_carbon FROM individual_total_carbon
ORDER BY carbon_emission DESC; 

--question
--gender proportion for jetblue
SELECT FirstName, LastName, Airline, count(a.Id) AS Number_of_flight
FROM Account a
LEFT JOIN Trip t ON a.Id = t.Id
LEFT JOIN Booking b ON t.TripId = b.TripId
LEFT JOIN Flight f ON f.BookingId = b.BookingId
LEFT JOIN Airlines air ON air.AirlineId = f.AirlineId
WHERE Airline IS NOT NULL
	AND Date BETWEEN '02/01/2021' AND '03/01/2021'
GROUP BY FirstName, LastName, Airline
ORDER BY Number_of_flight DESC; 

--question
--bus and private car comparison
SELECT TransportType, 
	   CASE MONTH(Date) WHEN 1 THEN 'January' WHEN 2 THEN 'February' ELSE 'March' END month, 
	   COUNT(t.TripId) number_of_transportation
FROM Trip t JOIN  
	(SELECT c.TransportId, TripId
	FROM Carbon c 
	INNER JOIN Bus bu ON c.TransportId = bu.TransportId
	UNION ALL
	SELECT c.TransportId, TripId
	FROM Carbon c 
	INNER JOIN CarUse cu ON c.TransportId = cu.TransportId) tb
	ON t.TripId = tb.TripId
LEFT JOIN Account a ON a.Id = t.Id
LEFT JOIN Carbon c ON tb.TransportId = c.TransportId
WHERE YEAR(Date) = '2021'
GROUP BY TransportType, MONTH(Date)
ORDER BY TransportType;

CREATE INDEX DateIndex
ON Trip(Date); 

CREATE INDEX CareerIndex
ON Account(Career); 

--TRIGGER
CREATE TABLE CarbonTotal (
	TotalChangeId DECIMAL  NOT NULL PRIMARY KEY, 
	Id DECIMAL(12) NOT NULL FOREIGN KEY REFERENCES Account(Id), 
	OldTotal DECIMAL NOT NULL, 
	NewTotal DECIMAL NOT NULL, 
	UpdateDate DATE NOT NULL
); 

CREATE SEQUENCE TotalChangeSeq START WITH 1; 


CREATE TRIGGER CarbonTotalTrigger
ON Account
AFTER UPDATE
AS
BEGIN

	DECLARE @OldTotal DECIMAL = (SELECT CarbonTotal FROM DELETED); 
	DECLARE @NewTotal DECIMAL = (SELECT CarbonTotal FROM INSERTED);

	IF (@OldTotal <> @NewTotal)
		INSERT INTO CarbonTotal (TotalChangeId, Id, OldTotal, NewTotal, UpdateDate)
		VALUES (NEXT VALUE FOR TotalChangeSeq, (SELECT Id FROM INSERTED), 
				@OldTotal, @NewTotal, GETDATE()); 
END; 

UPDATE Account
SET CarbonTotal = (SELECT SUM(Miles * GasEmission) carbon_emission
					FROM Trip t JOIN  
						(SELECT c.TransportId, TripId
						FROM Carbon c 
						INNER JOIN Booking b ON c.TransportId = b.TransportId
						UNION ALL
						SELECT c.TransportId, TripId
						FROM Carbon c 
						INNER JOIN Bus bu ON c.TransportId = bu.TransportId
						UNION ALL
						SELECT c.TransportId, TripId


						FROM Carbon c 
						INNER JOIN CarUse cu ON c.TransportId = cu.TransportId) tb
						ON t.TripId = tb.TripId
					LEFT JOIN Account a ON a.Id = t.Id
					LEFT JOIN Carbon c ON tb.TransportId = c.TransportId
					WHERE FirstName = 'Jennifer' AND LastName = 'Johnson')
WHERE FirstName = 'Jennifer' AND LastName = 'Johnson'; 
 
SELECT * FROM CarbonTotal; 
SELECT * FROM Trip;
SELECT * FROM total_carbon; 

--UPDATE total_carbon SET carbon_emission = 86770
--WHERE FirstName = 'John'; 

--graph
SELECT FirstName, LastName, MONTH(Date) month, SUM(Miles * GasEmission) carbon_emission
INTO graph3
FROM Trip t JOIN  
	(SELECT c.TransportId, TripId
	FROM Carbon c 
	INNER JOIN Booking b ON c.TransportId = b.TransportId
	UNION ALL
	SELECT c.TransportId, TripId
	FROM Carbon c 
	INNER JOIN Bus bu ON c.TransportId = bu.TransportId
	UNION ALL
	SELECT c.TransportId, TripId
	FROM Carbon c 
	INNER JOIN CarUse cu ON c.TransportId = cu.TransportId) tb
	ON t.TripId = tb.TripId
LEFT JOIN Account a ON a.Id = t.Id
LEFT JOIN Carbon c ON tb.TransportId = c.TransportId
GROUP BY FirstName, LastName, MONTH(Date); 

drop table CarbonTotal; 

SELECT MONTH(Date) month, SUM(Miles * GasEmission) carbon_emission, c.TransportType
INTO graph2
FROM Trip t JOIN  
	(SELECT c.TransportId, TripId, c.TransportType
	FROM Carbon c 
	INNER JOIN Booking b ON c.TransportId = b.TransportId
	UNION ALL
	SELECT c.TransportId, TripId, c.TransportType
	FROM Carbon c 
	INNER JOIN Bus bu ON c.TransportId = bu.TransportId
	UNION ALL
	SELECT c.TransportId, TripId, c.TransportType
	FROM Carbon c 
	INNER JOIN CarUse cu ON c.TransportId = cu.TransportId) tb
	ON t.TripId = tb.TripId
LEFT JOIN Account a ON a.Id = t.Id
LEFT JOIN Carbon c ON tb.TransportId = c.TransportId
GROUP BY MONTH(Date), c.TransportType; 
SELECT * FROM graph2; 

drop table graph2; 






SELECT TransportType,
		CASE MONTH(Date) WHEN 1 THEN 'January' WHEN 2 THEN 'February' ELSE 'March' END month,
		COUNT (t.TripId) number_of_transportation
FROM Trip t JOIN
	(SELECT c. TransportId, TripId
	FROM Carbon c
	INNER JOIN Bus bu ON c.TransportId = bu.TransportId
	UNION ALL
	SELECT c.TransportId, TripId
	FROM Carbon c
	INNER JOIN CarUse cu ON c.TransportId = cu.TransportId) tb
	ON t. TripId = tb. TripId
LEFT JOIN Account a ON a. Id = t. Id
LEFT JOIN Carbon c ON tb.Transportid=c.Transportid
WHERE YEAR (Date) = '2021'
GROUP BY TransportType, MONTH(Date)
ORDER BY TransportType; 

SELECT FirstName, LastName, Airline, COUNT(a.Id) AS Number_of_flight
FROM Account a
LEFT JOIN Trip t ON a.Id = t.Id
LEFT JOIN Booking b ON t.TripId = b.BookingId
LEFT JOIN FLight f ON f.BookingId = b.BookingId
LEFT JOIN Airlines air ON air.AirlineId = f.AirlineId
WHERE Airline IS NOT NULL
	AND Date BETWEEN '02/01/2021' AND '03/01/2021'
GROUP BY FirstName, LastName, Airline
ORDER BY Number_of_flight DESC; 

