--01.
SELECT FirstName, LastName
	FROM Employees
   WHERE FirstName LIKE 'SA%'

--02.
SELECT FirstName, LastName
	FROM Employees
   WHERE LastName LIKE '%ei%'

--03.
SELECT FirstName
	FROM Employees
   WHERE HireDate BETWEEN '01/01/1995' AND '12/31/2005' 
   AND DepartmentID = 3 OR DepartmentID = 10

--04.
SELECT FirstName, LastName
	FROM Employees
   WHERE JobTitle NOT LIKE '%engineer%'

--05.
SELECT [Name]
	FROM Towns
   WHERE LEN([Name]) = 5 OR LEN([Name]) = 6
  ORDER BY [Name]

--06.
SELECT *
	FROM Towns
   WHERE [Name] LIKE 'M%' OR [Name] LIKE 'K%' OR [Name] LIKE 'B%' OR [Name] LIKE 'E%'
   ORDER BY [Name]

--07.
SELECT *
	FROM Towns
   WHERE [Name] NOT LIKE 'R%' AND [Name] NOT LIKE 'B%' AND [Name] NOT LIKE 'D%'
   ORDER BY [Name]

--08.
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
    FROM Employees
   WHERE DATEPART(YEAR, HireDate) > '2000'

--09.
SELECT FirstName, LastName
	FROM Employees
   WHERE LEN(LastName) = 5

--10.
SELECT EmployeeID, FirstName, LastName, Salary,
	DENSE_RANK() OVER
	  (PARTITION BY Salary ORDER BY EmployeeID) AS RANK
   FROM Employees
  WHERE Salary BETWEEN 10000 AND 50000
  ORDER BY Salary DESC

--11.
SELECT * FROM
	(SELECT EmployeeID, FirstName, LastName, Salary,
		DENSE_RANK() OVER
		  (PARTITION BY Salary ORDER BY EmployeeID) AS RANK
	   FROM Employees
	  WHERE Salary BETWEEN 10000 AND 50000) a
  WHERE RANK = 2
 ORDER BY Salary DESC

--12.
SELECT CountryName, IsoCode 
	FROM Countries
  WHERE LEN(CountryName) - LEN(REPLACE(CountryName, 'a', '')) >= 3
ORDER BY IsoCode

--13.
SELECT Peaks.PeakName, Rivers.RiverName, 
	LOWER((Peaks.PeakName) + SUBSTRING(Rivers.RiverName,2,LEN(Rivers.Rivername))) AS 'Mix' 
  FROM Peaks
    JOIN Rivers ON RIGHT(Peaks.PeakName, 1) = LEFT(Rivers.RiverName, 1)
ORDER BY Mix

--14.
SELECT TOP(50) [Name], FORMAT([Start], 'yyyy-MM-dd') FROM Games
  WHERE YEAR([Start]) IN (2011, 2012)
ORDER BY [Start], [Name]

--15.
SELECT Username, SUBSTRING (Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS [Email Provider]
	FROM Users
  ORDER BY [Email Provider], Username

--16.
SELECT Username, IpAddress
	FROM Users
  WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

--17.
SELECT [Name],
	CASE
		WHEN DATEPART(HOUR, [Start]) >= 0 AND DATEPART(HOUR, [Start]) < 12 THEN 'Morning'
		WHEN DATEPART(HOUR, [Start]) >= 12 AND DATEPART(HOUR, [Start]) < 18 THEN 'Afternoon'
		ELSE 'Evening'
	END AS 'Part of the Day',
	CASE
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration >= 4 AND Duration <= 6 THEN 'Short'
		WHEN Duration > 6 THEN 'Long'
		ELSE 'Extra Long'
	END AS 'Duration'
FROM Games
ORDER BY [Name], Duration, [Part of the Day]

--18.
CREATE TABLE Orders
(Id INT IDENTITY(1,1) PRIMARY KEY,
ProductName VARCHAR(50) NOT NULL,
OrderDate DATETIME NOT NULL)

INSERT INTO Orders VALUES
('Butter', '2016-09-19'),
('Milk', '2016-09-30'),
('Cheese', '2016-09-04'),
('Bread', '2015-12-20'),
('Tomatoes', '2015-12-30')

SELECT ProductName, OrderDate, 
	DATEADD(DAY, 3, OrderDate) AS 'Pay Due', 
	DATEADD(MONTH, 1, OrderDate) AS 'Deliver Due'
FROM Orders

--19.
CREATE TABLE PeopleTest
(Id INT IDENTITY(1,1) PRIMARY KEY,
Name VARCHAR(50) NOT NULL,
Birthdate DATETIME NOT NULL)

INSERT INTO PeopleTest VALUES
('Victor', '2000-12-07'),
('Steven', '1992-09-10'),
('Stephen', '1910-09-19'),
('John', '2010-01-06')

SELECT [Name],
	DATEDIFF(YEAR, Birthdate, GETDATE()) AS 'Age in Years',
	DATEDIFF(MONTH, Birthdate, GETDATE()) AS 'Age in Months',
	DATEDIFF(DAY, Birthdate, GETDATE()) AS 'Age in Days',
	DATEDIFF(MINUTE, Birthdate, GETDATE()) AS 'Age in Minutes'
  FROM PeopleTest