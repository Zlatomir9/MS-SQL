--01.
CREATE TABLE Countries(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL UNIQUE)

CREATE TABLE Customers(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25) NOT NULL,
LastName NVARCHAR(25) NOT NULL,
Gender CHAR(1) NOT NULL,
Age INT NOT NULL,
PhoneNumber CHAR(10),
CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL,
CONSTRAINT CH_Gender CHECK(Gender IN ('M', 'F')))

CREATE TABLE Products(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) NOT NULL,
[Description] NVARCHAR(250),
Recipe NVARCHAR(MAX),
Price MONEY NOT NULL,
CONSTRAINT CH_Price CHECK(Price > 0))

CREATE TABLE Feedbacks(
Id INT PRIMARY KEY IDENTITY,
[Description] NVARCHAR(255),
Rate DECIMAL (15,2) NOT NULL,
ProductId INT FOREIGN KEY REFERENCES Products(Id) NOT NULL,
CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL)

CREATE TABLE Distributors(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) NOT NULL UNIQUE,
AddressText NVARCHAR(30) NOT NULL,
Summary NVARCHAR(200) NOT NULL,
CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL)

CREATE TABLE Ingredients(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
[Description] NVARCHAR(200) NOT NULL,
OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL,
DistributorId INT FOREIGN KEY REFERENCES Distributors(Id) NOT NULL)

CREATE TABLE ProductsIngredients(
ProductId INT FOREIGN KEY REFERENCES Products(Id) NOT NULL,
IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id) NOT NULL,
PRIMARY KEY(ProductId, IngredientId))

--02.
INSERT INTO Distributors VALUES
('Deloitte & Touche', '6 Arch St #9757', 'Customizable neutral traveling', 2),
('Congress Title', '58 Hancock St', 'Customer loyalty', 13),
('Kitchen People', '3 E 31st St #77', 'Triple-buffered stable delivery', 1),
('General Color Co Inc', '6185 Bohn St #72', 'Focus group', 21),
('Beck Corporation', '21 E 64th Ave', 'Quality-focused 4th generation hardware', 23)

INSERT INTO Customers VALUES
('Francoise', 'Rautenstrauch', 'M', 15, '0195698399', 5),
('Kendra', 'Loud', 'F', 22, '0063631526', 11),
('Lourdes', 'Bauswell', 'M', 50, '0139037043', 8),
('Hannah', 'Edmison', 'F', 18, '0043343686', 1),
('Tom', 'Loeza', 'M', 31, '0144876096', 23),
('Queenie', 'Kramarczyk', 'F', 30, '0064215793', 29),
('Hiu', 'Portaro', 'M', 25, '0068277755', 16),
('Josefa', 'Opitz', 'F', 43, '0197887645', 17)

--03.
UPDATE Ingredients
	SET DistributorId = 35
	WHERE [Name] IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
	SET OriginCountryId = 14
	WHERE OriginCountryId = 8

--04.
DELETE FROM Feedbacks
	WHERE CustomerId = 14 OR ProductId = 5 

--05.
SELECT [Name], Price, [Description]
	FROM Products
	ORDER BY Price DESC, [Name]

--06.
SELECT f.ProductId, Rate, [Description], CustomerId, Age, Gender
	FROM Feedbacks f
	JOIN Customers c ON c.Id = f.CustomerId
	WHERE Rate < 5.0
	ORDER BY ProductId DESC, Rate ASC

--07.
SELECT CONCAT(FirstName, ' ', LastName) AS CustomerName,
	   PhoneNumber,
	   Gender
	FROM Customers c
	FULL JOIN Feedbacks f ON f.CustomerId = c.Id
	WHERE f.Id IS NULL
	ORDER BY c.Id

--08.
SELECT FirstName, Age, PhoneNumber
	FROM Customers
	WHERE Age >= 21 AND (FirstName LIKE '%an%' OR PhoneNumber LIKE '________38')
					AND CountryId != 31
  ORDER BY FirstName, Age DESC

--09.
SELECT d.[Name] AS DistributorName, 
	   i.[Name] AS IngredientName, 
	   p.[Name] AS ProductName, 
	   AVG(f.Rate) AS AverageRate
	FROM Distributors d
	JOIN Ingredients i ON i.DistributorId = d.Id
	JOIN ProductsIngredients [pi] ON [pi].IngredientId = i.Id
	JOIN Products p ON [pi].ProductId = p.Id
	JOIN Feedbacks f ON f.ProductId = p.Id
  GROUP BY d.[Name], i.[Name], p.[Name]
  HAVING AVG(f.Rate) BETWEEN 5 AND 8
  ORDER BY d.[Name], i.[Name], p.[Name]

--10.
SELECT  c.[Name] AS CountryName, r.[Name] AS DisributorName
    FROM 
        (SELECT d.[Name], 
				d.CountryId, 
				DENSE_RANK() OVER (PARTITION BY d.CountryId ORDER BY COUNT(i.Id) DESC) AS Ranked
			FROM Ingredients i 
			JOIN Distributors d ON d.Id = i.DistributorId
        GROUP BY d.[Name], d.CountryId) AS r
    JOIN Countries c ON c.Id = r.CountryId
		WHERE Ranked = 1
    GROUP BY  c.[Name], r.[Name]
    ORDER BY c.[Name], r.[Name]

--11.
CREATE VIEW v_UserWithCountries AS
SELECT FirstName + ' ' + LastName AS CustomerName,
	   c.Age,
	   c.Gender,
	   ct.[Name]
	FROM Customers c
	JOIN Countries ct ON ct.Id = c.CountryId

SELECT TOP 5 *
  FROM v_UserWithCountries
 ORDER BY Age