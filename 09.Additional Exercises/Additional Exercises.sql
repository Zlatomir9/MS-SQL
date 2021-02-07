--01.
SELECT SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email) - CHARINDEX('@', Email))
	AS EmailProvider, COUNT(*)
	FROM Users
	GROUP BY SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email) - CHARINDEX('@', Email))
	ORDER BY COUNT(*) DESC, EmailProvider ASC

--02.
SELECT g.Name AS Game, gt.Name AS [Game Type], u.Username, ug.Level, ug.Cash, c.Name AS Character
	FROM Users u
	JOIN UsersGames ug ON u.Id = ug.UserId
	JOIN Characters c ON c.Id = ug.CharacterId
	JOIN Games g ON g.Id = ug.GameId
	JOIN GameTypes gt ON gt.Id = g.GameTypeId
	ORDER BY ug.Level DESC, u.Username, g.Name

--03.
SELECT u.Username, g.Name AS Game, COUNT(i.Id) AS [Items Count], SUM(i.Price) AS [Items Price]
	FROM Users u
	JOIN UsersGames ug ON u.Id = ug.UserId
	JOIN Games g ON g.Id = ug.GameId
	JOIN UserGameItems ugi ON ug.Id = ugi.UserGameId
	JOIN Items i ON ugi.ItemId = i.Id
  GROUP BY u.Username, g.Name
  HAVING COUNT(i.Id) >= 10
  ORDER BY COUNT(i.Id) DESC, SUM(i.Price) DESC, u.Username

--04.
SELECT  u.Username, 
		g.[Name], 
		MAX(c.[Name]) AS [Character], 
		SUM(its.Strength) + MAX(gts.Strength) + MAX(cs.Strength) AS Strength,
		SUM(its.Defence) + MAX(gts.Defence) + MAX(cs.Defence) AS Defence,
		SUM(its.Speed) + MAX(gts.Speed) + MAX(cs.Speed) AS Speed,
		SUM(its.Mind) + MAX(gts.Mind) + MAX(cs.Mind) AS Mind,
		SUM(its.Luck) + MAX(gts.Luck) + MAX(cs.Luck) AS Luck
	FROM Users u
	JOIN UsersGames ug on ug.UserId = u.Id
	JOIN Games g on ug.GameId = g.Id
	JOIN GameTypes gt on gt.Id = g.GameTypeId
	JOIN [Statistics] gts on gts.id = gt.BonusStatsId
	JOIN Characters c on ug.CharacterId = c.Id
	JOIN [Statistics] cs on cs.Id = c.StatisticId
	JOIN UserGameItems ugi on ugi.UserGameId = ug.id
	JOIN Items i on i.Id = ugi.ItemId
	JOIN [Statistics] its on its.Id = i.StatisticId
  GROUP BY u.Username, g.[Name]
  ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC

--05.
SELECT i.[Name], i.Price, i.MinLevel, s.Strength, s.Defence, s.Speed, s.Luck, s.Mind
	FROM Items i
	JOIN [Statistics] s ON s.Id = i.StatisticId
	WHERE s.Mind > (SELECT AVG(Mind) FROM [Statistics])
      AND s.Luck > (SELECT AVG(Luck) FROM [Statistics]) 
	  AND s.Speed > (SELECT AVG(Speed) FROM [Statistics])
  ORDER BY i.[Name]

--06.
SELECT i.[Name] AS Item, i.Price, i.MinLevel, gt.[Name] AS [Forbidden Game Type]
	FROM Items i
	FULL JOIN GameTypeForbiddenItems gtfi ON gtfi.ItemId = i.Id
	FULL JOIN GameTypes gt ON gt.Id = gtfi.GameTypeId
  ORDER BY gt.[Name] DESC, i.[Name]

--07.
DECLARE @userGameId INT = (SELECT Id FROM UsersGames AS ug 
	WHERE ug.GameId = (SELECT Id FROM Games WHERE Name LIKE 'Edinburgh') 
	AND ug.UserId = (SELECT Id FROM Users WHERE Username LIKE 'Alex'))

DECLARE @boughtItemsPrice MONEY = (SELECT SUM(Price) FROM Items WHERE Name IN (
'Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 
'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'))

DECLARE @GameID INT = (Select GameId FROM UsersGames WHERE Id = @userGameId)

INSERT UserGameItems
	SELECT i.Id, @userGameId
	FROM Items AS i
	WHERE i.[Name] IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 
'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet')

UPDATE UsersGames
SET Cash = Cash - @boughtItemsPrice
WHERE Id = @userGameId

SELECT u.Username, g.[Name], ug.Cash, i.[Name] AS [Item Name]
	FROM Users u
	JOIN UsersGames ug ON ug.UserId = u.Id
	JOIN Games g ON g.Id = ug.GameId
	JOIN UserGameItems ugi ON ugi.UserGameId = ug.Id
	JOIN Items i ON i.Id = ugi.ItemId
  WHERE ug.GameId = @GameID
  ORDER BY [Item Name]

--08.
SELECT p.PeakName, m.MountainRange AS Mountain, p.Elevation
	FROM Peaks p
	JOIN Mountains m ON p.MountainId = m.Id
  ORDER BY p.Elevation DESC, p.PeakName

--09.
SELECT p.PeakName, m.MountainRange, c.CountryName, ct.ContinentName
	FROM Peaks p
	JOIN Mountains m ON p.MountainId = m.Id
	JOIN MountainsCountries mc ON mc.MountainId = m.Id
	JOIN Countries c ON c.CountryCode = mc.CountryCode
	JOIN Continents ct ON ct.ContinentCode = c.ContinentCode
  ORDER BY p.PeakName, c.CountryName

--10.
SELECT c.CountryName, 
	   ct.ContinentName, 
			CASE
				WHEN COUNT(r.RiverName) = 0 THEN 0
				ELSE COUNT(r.RiverName)
			END AS RiversCount,
			CASE
				WHEN SUM(r.Length) IS NULL THEN 0
				ELSE SUM(r.Length)
			END AS TotalLength
	FROM Rivers r
	FULL JOIN CountriesRivers cr ON cr.RiverId = r.Id
	FULL JOIN Countries c ON c.CountryCode = cr.CountryCode
	FULL JOIN Continents ct ON ct.ContinentCode = c.ContinentCode
  GROUP BY c.CountryName, ct.ContinentName
  ORDER BY COUNT(r.RiverName) DESC, SUM(r.Length) DESC, c.CountryName

--11.
SELECT cr.CurrencyCode, cr.[Description] AS Currency, COUNT(ct.CountryName) AS NumberOfCountries
	FROM Currencies cr
	LEFT JOIN Countries ct ON ct.CurrencyCode = cr.CurrencyCode
  GROUP BY cr.CurrencyCode, cr.[Description]
  ORDER BY NumberOfCountries DESC, Currency

--12.
SELECT c.ContinentName, 
	   SUM(CAST(ct.AreaInSqKm AS BIGINT)) AS CountriesArea,
	   SUM(CAST(ct.[Population] AS BIGINT)) AS CountriesPopulation
	FROM Continents c
	JOIN Countries ct ON ct.ContinentCode = c.ContinentCode
  GROUP BY c.ContinentName
  ORDER BY CountriesPopulation DESC

--13.
CREATE TABLE Monasteries(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50),
	CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode)
);

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

ALTER TABLE Countries
ADD IsDeleted BIT NOT NULL DEFAULT 0;

UPDATE Countries
SET IsDeleted = 1
WHERE CountryCode IN (SELECT c.CountryCode
	FROM Countries c 
	JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
	JOIN Rivers r ON r.Id = cr.RiverId
  GROUP BY c.CountryCode
  HAVING COUNT(r.RiverName) > 3)

SELECT m.[Name] AS Monastery, c.CountryName AS Country
	FROM Countries c
	JOIN Monasteries m ON m.CountryCode = c.CountryCode
	WHERE c.IsDeleted = 0
  ORDER BY m.[Name]

--14.
UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries VALUES
('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania'))

INSERT INTO Monasteries VALUES
('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))

SELECT c.ContinentName, cr.CountryName, COUNT(m.[Name]) AS MonasteriesCount
	FROM Continents c
	LEFT JOIN Countries cr ON cr.ContinentCode = c.ContinentCode
	LEFT JOIN Monasteries m ON m.CountryCode = cr.CountryCode
	WHERE cr.IsDeleted = 0
  GROUP BY c.ContinentName, cr.CountryName
  ORDER BY MonasteriesCount DESC, cr.CountryName