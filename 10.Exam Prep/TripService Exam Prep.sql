--01.
CREATE TABLE Cities(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
CountryCode CHAR(2) NOT NULL)

CREATE TABLE Hotels(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
EmployeeCount INT NOT NULL,
BaseRate DECIMAL(15,2))

CREATE TABLE Rooms(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL(15,2) NOT NULL,
[Type] NVARCHAR(20) NOT NULL,
Beds INT NOT NULL,
HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL)

CREATE TABLE Trips(
Id INT PRIMARY KEY IDENTITY,
RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
BookDate DATETIME NOT NULL, 
ArrivalDate DATETIME NOT NULL,
ReturnDate DATETIME NOT NULL,
CancelDate DATETIME,
CONSTRAINT CH_Trips_ArrivalDate CHECK(BookDate < ArrivalDate),
CONSTRAINT CH_Trips_ReturnDate CHECK(ArrivalDate < ReturnDate))

CREATE TABLE Accounts(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(50),
LastName NVARCHAR(50) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
BirthDate DATETIME NOT NULL,
Email VARCHAR(100) UNIQUE NOT NULL)

CREATE TABLE AccountsTrips(
AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
TripId INT FOREIGN KEY REFERENCES Trips(Id),
Luggage INT NOT NULL,
CONSTRAINT CH_Trips_PositiveLuggage CHECK(Luggage >= 0),
PRIMARY KEY(AccountId, TripId))

--02.
INSERT INTO Accounts VALUES
('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)

--03.
UPDATE Rooms
SET Price += Price * 0.14
WHERE HotelId IN (5, 7, 9)

--04.
DELETE FROM AccountsTrips WHERE AccountId = 47

--05.
SELECT FirstName, 
	   LastName, 
	   FORMAT(BirthDate, 'MM-dd-yyyy') AS BirthDate, 
	   c.[Name] AS Hometown, 
	   Email
	FROM Accounts a
	JOIN Cities c ON a.CityId = c.Id 
	WHERE Email LIKE 'e%'
  ORDER BY c.[Name]

--06.
SELECT c.[Name] AS City, COUNT(h.[Name]) AS Hotels
	FROM Cities c
	JOIN Hotels h ON h.CityId = c.Id
  GROUP BY c.[Name]
  ORDER BY Hotels DESC, City

--07.
SELECT a.Id, 
	   CONCAT(FirstName, ' ', LastName) AS FullName,
	   MAX(DATEDIFF(DAY, ArrivalDate, ReturnDate)) AS LongestTrip,
	   MIN(DATEDIFF(DAY, ArrivalDate, ReturnDate)) AS ShortestTrip
	FROM Trips t
	JOIN AccountsTrips [at] ON [at].TripId = t.Id
	JOIN Accounts a ON a.Id = [at].AccountId
	WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
  GROUP BY a.Id, CONCAT(FirstName, ' ', LastName)
  ORDER BY LongestTrip DESC, ShortestTrip

--08.
SELECT TOP(10) c.Id, c.[Name], c.CountryCode, COUNT(a.Id) AS Accounts
	FROM Cities c
	JOIN Accounts a ON c.Id = a.CityId
  GROUP BY c.Id, c.[Name], c.CountryCode
  ORDER BY Accounts DESC

--09.
SELECT a.Id, a.Email, c.[Name] AS City, COUNT(t.Id) AS Trips
	FROM Accounts a
	JOIN AccountsTrips [at] ON [at].AccountId = a.Id
	JOIN Trips t ON t.Id = [at].TripId
	JOIN Rooms r ON r.Id = t.RoomId
	JOIN Hotels h ON h.Id = r.HotelId
	JOIN Cities c ON c.Id = h.CityId
	WHERE c.Id = a.CityId
  GROUP BY a.Id, a.Email, c.[Name]
  ORDER BY Trips DESC, a.Id

--10.
SELECT t.Id,
	   CASE 
			WHEN a.MiddleName IS NULL THEN CONCAT(a.FirstName, ' ', a.LastName)
			ELSE CONCAT(a.FirstName, ' ', a.MiddleName, ' ', a.LastName)
	   END AS FullName,
	   (SELECT ct.[Name] FROM Cities ct WHERE ct.Id = a.CityId) AS [From],
	   c.[Name] AS [To],
	   CASE
			WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
			ELSE CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
	   END AS Duration
	FROM Trips t
	JOIN AccountsTrips [at] ON t.Id = [at].TripId
	JOIN Accounts a ON [at].AccountId = a.Id
	JOIN Rooms r ON t.RoomId = r.Id
	JOIN Hotels h ON r.HotelId = h.Id
	JOIN Cities c ON h.CityId = c.Id
	ORDER BY FullName, t.Id

--11.
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATETIME, @People INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Result NVARCHAR(MAX)

	DECLARE @Rooms TABLE(RoomId INT NOT NULL)
 
	INSERT INTO @Rooms
	SELECT r.Id FROM Rooms r 
	JOIN Hotels h ON h.Id = r.HotelId
	WHERE (h.Id = @HotelId) AND r.Beds >= @People 
	ORDER BY R.Price DESC
 
	DECLARE @AvailableRoom INT = (SELECT TOP(1) r.RoomId FROM @Rooms r
							JOIN Trips t ON t.Id=r.RoomId
							WHERE @Date NOT BETWEEN t.ArrivalDate AND t.ReturnDate)

	IF(@AvailableRoom IS NULL)
	  BEGIN
		SET @Result = 'No rooms available'
	  END

	ELSE
	  BEGIN
		DECLARE @RoomId INT = (SELECT TOP(1) r.Id FROM Rooms r 
						   JOIN Hotels h ON r.HotelId = h.Id
						   JOIN Trips t ON t.RoomId = r.Id
						   WHERE h.Id = @HotelId AND r.Beds >= @People 
						   AND @Date NOT BETWEEN t.ArrivalDate AND t.ReturnDate
						   ORDER BY r.Price DESC)
		DECLARE @RoomPrice DECIMAL(15,2) = ((SELECT h.BaseRate FROM Hotels h 
				JOIN Rooms r ON h.Id = r.HotelId WHERE r.Id = @RoomId) + (SELECT Price FROM Rooms r 
				WHERE r.Id = @RoomId)) * @People
		SET @Result = CONCAT('Room ', @RoomId,': ', 
					  (SELECT r.[Type] FROM Rooms r WHERE r.Id = @RoomId),
					  ' (', (SELECT r.Beds FROM Rooms r WHERE r.Id = @RoomId),
					  ' beds) - $',
					  @RoomPrice)
	  END
	RETURN @Result
END

SELECT dbo.udf_GetAvailableRoom (94, '2015-07-26', 3)

--12.
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
	DECLARE @TripHotelId INT = (SELECT h.Id FROM Hotels h
							   JOIN Rooms r ON h.Id = r.HotelId
							   JOIN Trips t ON r.Id = t.RoomId
							   WHERE t.Id = @TripId)
	DECLARE @TargetRoomHotelId INT = (SELECT h.Id FROM Hotels h
									  JOIN Rooms r ON h.Id = r.HotelId
									  WHERE r.Id = @TargetRoomId)
	IF(@TripHotelId != @TargetRoomHotelId)
	
	BEGIN
		RAISERROR('Target room is in another hotel!', 16, 1)
		RETURN
	END

	DECLARE @TargetRoomBeds INT = (SELECT Beds FROM Rooms
								   WHERE @TargetRoomId = Id)

	DECLARE @TripAccBeds INT = (SELECT COUNT(a.Id) FROM Accounts a
								JOIN AccountsTrips atr ON a.Id = atr.AccountId
								JOIN Trips t ON atr.TripId = t.Id
								WHERE t.Id = @TripId
								GROUP BY t.Id)

	IF(@TargetRoomBeds < @TripAccBeds)
	BEGIN
		RAISERROR ('Not enough beds in target room!', 16, 1)
		RETURN
	END

	ELSE 
	BEGIN
		UPDATE Trips
		SET RoomId = @TargetRoomId
	END