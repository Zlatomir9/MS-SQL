--01.
USE ColonialJourney
CREATE TABLE Planets(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL)

CREATE TABLE Spaceports(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL)

CREATE TABLE Spaceships(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
Manufacturer NVARCHAR(30) NOT NULL,
LightSpeedRate INT DEFAULT 0)

CREATE TABLE Colonists(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(20) NOT NULL,
LastName NVARCHAR(20) NOT NULL,
Ucn NVARCHAR(10) NOT NULL UNIQUE,
BirthDate DATETIME NOT NULL)

CREATE TABLE Journeys(
Id INT PRIMARY KEY IDENTITY,
JourneyStart DATETIME NOT NULL,
JourneyEnd DATETIME NOT NULL,
Purpose NVARCHAR(11) NOT NULL,
DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id),
CONSTRAINT CH_Purpose CHECK(Purpose IN ('Medical', 'Technical', 'Educational', 'Military')))

CREATE TABLE TravelCards(
Id INT PRIMARY KEY IDENTITY,
CardNumber NCHAR(10) NOT NULL UNIQUE,
JobDuringJourney NVARCHAR(8) NOT NULL,
ColonistId INT FOREIGN KEY REFERENCES Colonists(Id) NOT NULL,
JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL,
CONSTRAINT CH_JobDuringJourney CHECK(JobDuringJourney IN 
('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')))

--02.
INSERT INTO Planets VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda', 4),
('Falcon9', 'SpaceX', 1),
('Bed', 'Vidolov', 6)

--03.
UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12

--04.
ALTER TABLE TravelCards WITH CHECK ADD CONSTRAINT [FK_TravelCar_Journ_35BCFE0A] FOREIGN KEY(JourneyId)
REFERENCES Journeys (Id)
ON DELETE CASCADE

DELETE FROM Journeys
WHERE Id IN (1, 2, 3)

--05.
SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy'), FORMAT(JourneyEnd, 'dd/MM/yyyy')
	FROM Journeys
	WHERE Purpose LIKE 'Military'
	ORDER BY JourneyStart

--06.
SELECT c.Id, CONCAT(FirstName, ' ', LastName)
	FROM Colonists c
	JOIN TravelCards tc ON tc.ColonistId = c.Id
	WHERE tc.JobDuringJourney LIKE 'Pilot'
	ORDER BY c.Id

--07.
SELECT COUNT(c.Id)
	FROM Journeys j
	JOIN TravelCards tc ON tc.JourneyId = j.Id
	JOIN Colonists c ON c.Id = tc.ColonistId
	WHERE j.Purpose LIKE 'Technical'
	GROUP BY j.Purpose

--08.
SELECT s.[Name], s.Manufacturer
	FROM Spaceships s 
	JOIN Journeys j ON j.SpaceshipId = s.Id
	JOIN TravelCards tc ON tc.JourneyId = j.Id
	JOIN Colonists c ON c.Id = tc.ColonistId
  WHERE DATEDIFF(YEAR, BirthDate, '2019-01-01') < 30 AND tc.JobDuringJourney LIKE 'Pilot'
  ORDER BY s.[Name]

--09.
SELECT p.[Name], COUNT(j.Id)
	FROM Journeys j
	JOIN Spaceports sp ON sp.Id = j.DestinationSpaceportId
	JOIN Planets p ON sp.PlanetId = p.Id
  GROUP BY p.[Name]
  ORDER BY COUNT (j.Id) DESC, p.[Name]

--10.
SELECT * 
	FROM (SELECT tc.JobDuringJourney, 
	      CONCAT(c.FirstName, ' ', c.LastName) AS [FullName],
		  RANK () OVER (PARTITION BY tc.JobDuringJourney ORDER BY Birthdate) AS JobRank
		FROM Colonists c
		JOIN TravelCards tc ON tc.ColonistId = c.Id
		JOIN Journeys j ON j.Id = tc.JourneyId) AS r
	WHERE r.JobRank = 2

--11.
CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
AS
BEGIN
	DECLARE @Count INT
	SELECT @Count = COUNT(c.Id)
		FROM Colonists c
		JOIN TravelCards tc ON tc.ColonistId = c.Id
		JOIN Journeys j ON j.Id = tc.JourneyId
		JOIN Spaceports sp ON sp.Id = j.DestinationSpaceportId		
		JOIN Planets p ON p.Id = sp.PlanetId
	  WHERE p.[Name] = @PlanetName
    RETURN @Count
END

SELECT dbo.udf_GetColonistsCount('Otroyphus')

--12.
CREATE PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose NVARCHAR(11))
AS
BEGIN
	 IF((SELECT Id FROM Journeys WHERE Id = @JourneyId) IS NULL)
		RAISERROR('The journey does not exist!', 15, 1)
	 IF((SELECT Purpose FROM Journeys WHERE Id = @JourneyId) LIKE @NewPurpose)
		RAISERROR('You cannot change the purpose!', 15, 1)
	 ELSE
		UPDATE Journeys
		SET Purpose = @NewPurpose
		WHERE Id = @JourneyId
END

EXEC usp_ChangeJourneyPurpose 2, 'Educational'