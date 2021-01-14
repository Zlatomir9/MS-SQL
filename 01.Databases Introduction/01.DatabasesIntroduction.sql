CREATE DATABASE Minions

CREATE TABLE Minions
(
	Id INT PRIMARY KEY,
	[Name] VARCHAR(30),
	Age INT
)

CREATE TABLE Towns
(
	Id INT PRIMARY KEY,
	[Name] VARCHAR(50)
)

ALTER TABLE Minions
ADD TownId INT

ALTER TABLE Minions
ADD FOREIGN KEY (TownId) REFERENCES Towns(Id)

INSERT INTO Towns (Id, Name) VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions (Id, Name, Age, TownId) VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)

DROP TABLE Minions
DROP TABLE Towns

CREATE TABLE Users
(
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL, 
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARCHAR (MAX),
	LastLoginTime DATETIME,
	IsDeleted BIT
)

INSERT INTO Users 
(Username, [Password], ProfilePicture, LastLoginTime, IsDeleted)
VALUES
('gosho', 'strong123','', '1/12/2020', 0),
('pesho', 'dsdsadas', '', '4/4/2020', 0),
('gg', 'gfdgdgd', '', '5/5/2020', 0),
('gop', 'wqedsadsa', '', '6/6/2020', 0),
('gdsadsa', 'dsadsa', '', '7/7/2020', 0)

ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC07043C2576

ALTER TABLE Users
ADD CONSTRAINT PK_IdUsername PRIMARY KEY (Id, Username)

ALTER TABLE Users
ADD CONSTRAINT CH_PasswordIsAtleast5Symbols CHECK (LEN(Password) > 5)

ALTER TABLE Users
ADD CONSTRAINT DF_LastLoginTime DEFAULT GETDATE() FOR LastLoginTime

ALTER TABLE Users
DROP CONSTRAINT PK_IdUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Id PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CH_UsernameIsAtleast3Symbols CHECK (LEN(Username) > 3)

CREATE DATABASE Hotel

USE Hotel

CREATE TABLE Employees
(
	Id INT PRIMARY KEY,
	FirstName VARCHAR(90) NOT NULL,
	LastName VARCHAR(90) NOT NULL,
	Title VARCHAR(50) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Employees(Id, FirstName, LastName, Title, Notes) VALUES
(1, 'Gosho', 'Goshev', 'CEO', NULL), 
(2, 'Petar', 'Ivanov', 'KKK', 'noteeeeee'), 
(3, 'Tosho', 'TTTTTT', 'TTT', NULL) 

CREATE TABLE Customers
(
	AccountNumber INT PRIMARY KEY,
	FirstName VARCHAR(90) NOT NULL,
	LastName VARCHAR(90) NOT NULL,
	PhoneNumber CHAR(10) NOT NULL,
	EmergencyName VARCHAR(90) NOT NULL,
	EmergencyNumber VARCHAR(10) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Customers VALUES
(120, 'T', 'Y', '231329139', 'KK', '546646465', NULL),
(121, 'rr', 'ww', '4561', 'dsa', '87956', NULL),
(123, 'vv', 'qq', '123456', 'kodksiak', '999999', NULL)

CREATE TABLE RoomStatus
(
	RoomStatus VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO RoomStatus VALUES
('Cleaning', NULL),
('Free', NULL),
('Not Free', NULL)

CREATE TABLE RoomTypes
(
	RoomType VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO RoomTypes VALUES
('Apartment', NULL),
('Single', NULL),
('Child', NULL)

CREATE TABLE BedTypes
(
	BedType VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO BedTypes VALUES
('Single', NULL),
('Double', NULL),
('ChildBed', NULL)

CREATE TABLE Rooms
(
	RoomNumber INT PRIMARY KEY,
	RoomType VARCHAR(20) NOT NULL,
	BedType VARCHAR(20) NOT NULL,
	Rate INT,
	RoomStatus BIT NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Rooms VALUES
(120, 'Apartment', 'Single', 10, 1, NULL),
(121, 'Bedroom', 'Double', 15, 0, NULL),
(122, 'Apartment', 'Single', 16, 1, NULL)

CREATE TABLE Payments
(
	Id INT PRIMARY KEY,
	EmployeeId INT NOT NULL,
	PaymentDate DATETIME NOT NULL,
	AccountNumber INT NOT NULL,
	FirstDateOccupied DATETIME NOT NULL,
	LastDateOccupied DATETIME NOT NULL,
	TotalDays INT NOT NULL,
	AmountCharged DECIMAL(15,2),
	TaxRate INT,
	TaxAmount INT,
	PaymentTotal DECIMAL(15, 2),
	Notes VARCHAR(MAX)
)

INSERT INTO Payments VALUES
(1, 1, GETDATE(), 120, '5/5/2012', '5/8/2012', 3, 450.23, NULL, NULL, 450.23, NULL),
(2, 2, GETDATE(), 121, '6/6/2012', '6/8/2012', 3, 150.69, NULL, NULL, 150.69, NULL),
(3, 3, GETDATE(), 122, '7/5/2012', '7/8/2012', 3, 999.23, NULL, NULL, 999.23, NULL)

CREATE TABLE Occupancies
(
	Id INT PRIMARY KEY,
	EmployeeId INT NOT NULL,
	DateOccupied DATETIME NOT NULL,
	AccountNumber INT NOT NULL,
	RoomNumber INT NOT NULL,
	RateApplied INT,
	PhoneCharge DECIMAL(15,2),
	Notes VARCHAR(MAX)
)

INSERT INTO Occupancies VALUES
(1, 120, GETDATE(), 120, 120, 0, 0, NULL),
(2, 121, GETDATE(), 121, 121, 0, 0, NULL),
(3, 122, GETDATE(), 122, 122, 0, 0, NULL)

--07.
	CREATE TABLE People
	(
		Id INT PRIMARY KEY,
		[Name] VARCHAR(200) NOT NULL,
		Picture VARCHAR(MAX),
		Height DECIMAL(15,2),
		[Weight] DECIMAL (15,2),
		Gender CHAR(1) CHECK (Gender='f' OR Gender = 'm') NOT NULL,
		Birthdate DATETIME,
		Biography VARCHAR(MAX)
	)

	INSERT INTO People VALUES
	(1, 'Gosho', NULL, 1.55, 55.22, 'm', '1/1/1999', NULL),
	(2, 'Toshka', 'some pretty pic', NULL, NULL, 'f', '1/1/2021', NULL),
	(3, 'Penka', NULL, 1.25, 22.11, 'f', '4/25/2000', NULL),
	(4, 'Petar', NULL, NULL, 66, 'm', '10/1/1999', 'biographyyyy'),
	(5, 'Nik', NULL, 2.05, 100.24, 'm', '12/29/1965', NULL)

--13.
CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors
(
	Id INT PRIMARY KEY,
	DirectorName VARCHAR(20) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Directors VALUES
(1, 'Gosho', NULL),
(2, 'Pesho', NULL),
(3, 'Petar', NULL),
(4, 'Steven', NULL),
(5, 'AJ', 'taking notes')

CREATE TABLE Genres
(
	Id INT PRIMARY KEY,
	GenreName VARCHAR(50) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Genres VALUES
(1, 'Horror', NULL),
(2, 'Action', NULL),
(3, 'Comedy', NULL),
(4, 'Love story', 'not good'),
(5, 'Drama', 'cry')

CREATE TABLE Categories
(
	Id INT PRIMARY KEY,
	CategoryName VARCHAR(50) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Categories VALUES
(1, 'Horror', NULL),
(2, 'Action', NULL),
(3, 'Comedy', NULL),
(4, 'Love story', 'not good'),
(5, 'Drama', 'cry')

CREATE TABLE Movies
(
	Id INT PRIMARY KEY,
	Title VARCHAR(50) NOT NULL,
	DirectorId INT NOT NULL,
	CopyrightYear DATETIME NOT NULL,
	[Length] DECIMAL (15,2) NOT NULL,
	GenreId INT NOT NULL,
	CategoryId INT,
	Rating DECIMAL (15,2),
	Notes VARCHAR(MAX)
)

INSERT INTO Movies VALUES
(1, 'Bad', 1, '10/1/1995', 125.55, 1, 1, 9.99, NULL),
(2, 'dsadsad', 2, '1/12/2000', 125.55, 1, 1, 9.99, NULL),
(3, 'vcbvc', 3, '5/5/2001', 125.55, 1, 1, 9.99, NULL),
(4, 'wqewqe', 4, '6/6/2002', 125.55, 1, 1, 9.99, NULL),
(5, 'hgrhrhr', 5, '7/7/2003', 125.55, 1, 1, 9.99, NULL)

--14

CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories
(
	Id INT PRIMARY KEY,
	CategoryName VARCHAR(30) NOT NULL,
	DailyRate DECIMAL (15,2),
	WeeklyRate DECIMAL (15,2),
	MonthlyRate DECIMAL (15,2),
	WeekendRate DECIMAL (15,2)
)

INSERT INTO Categories VALUES
(1, 'Sports', 5.55, 6.66, 8.00, 9.99),
(2, 'Family', 9.99, 5.55, 7.87, 1.00),
(3, 'Luxury', 1.11, 2.22, 3.30, 4.44)

CREATE TABLE Cars
(
	Id INT PRIMARY KEY,
	PlateNumber VARCHAR(20) NOT NULL,
	Manufacturer VARCHAR(50) NOT NULL,
	Model VARCHAR(50) NOT NULL,
	CarYear INT NOT NULL,
	CategoryId INT NOT NULL,
	Doors TINYINT NOT NULL,
	Picture VARCHAR(MAX),
	Condition VARCHAR(MAX),
	Available BIT
)

INSERT INTO Cars VALUES
(1, 'pl213', 'mb', 'c', 2002, 1, 3, NULL, NULL, 1),
(2, 'gg333', 'bmw', '3', 2005, 2, 5, NULL, NULL, 0),
(3, 'cry123', 'audi', 'a3', 2012, 3, 3, NULL, NULL, 1)

CREATE TABLE Employees
(
	Id INT PRIMARY KEY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Title VARCHAR(30),
	Notes VARCHAR(MAX)
)

INSERT INTO Employees VALUES
(1, 'gosho', 'b', 'c', NULL),
(2, 'gpdsa', 'm', 'n', NULL),
(3, 'gdsadsadsa', 'v', 'p', NULL)

CREATE TABLE Customers
(
	Id INT PRIMARY KEY,
	DriverLicenceNumber VARCHAR(30) NOT NULL,
	FullName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(50) NOT NULL,
	City VARCHAR(50) NOT NULL,
	ZIPCode INT NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Customers VALUES
(1, 'pl21313', 'b', 'c', 'pld', 4, NULL),
(2, 'ldpsadkosa', 'v', 'f', 'sf', 6, NULL),
(3, 'dsadsafsa', 'gg', 'gg', 'vr', 1, NULL)

CREATE TABLE RentalOrders
(
	Id INT PRIMARY KEY,
	EmployeeId INT NOT NULL,
	CustomerId INT NOT NULL,
	CarId INT NOT NULL,
	TankLevel INT NOT NULL,
	KilometrageStart INT NOT NULL,
	KilometrageEnd INT NOT NULL,
	TotalKilometrage INT NOT NULL,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NOT NULL,
	TotalDays INT NOT NULL,
	RateApplied DECIMAL (15,2),
	TaxRate INT NOT NULL,
	OrderStatus BIT NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO RentalOrders VALUES
(1, 1, 1, 1, 10, 100, 200, 300, '1/1/2000', '1/5/2000', 4, NULL, 15, 1, NULL),
(2, 2, 2, 2, 20, 1000, 2000, 3000, '1/2/2001', '1/6/2001', 4, NULL, 5, 0, NULL),
(3, 3, 3, 3, 15, 1500, 2000, 3500, '1/10/2010', '1/15/2010', 5, NULL, 25, 1, NULL)

--16.

CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns
(
	Id INT PRIMARY KEY,
	[Name] VARCHAR(30)
)

INSERT INTO Towns VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna'),
(4, 'Burgas')

CREATE TABLE Addresses 
(
	Id INT PRIMARY KEY,
	AddressText VARCHAR(30),
	TownId INT,
    FOREIGN KEY (TownId) REFERENCES Towns(Id)
)

CREATE TABLE Departments 
(
	Id INT PRIMARY KEY,
	[Name] VARCHAR(30)
)

INSERT INTO Departments VALUES
(1, 'Engineering'),
(2, 'Sales'),
(3, 'Marketing'),
(4, 'Software Development'),
(5, 'Quality Assurance')

CREATE TABLE Employees
(
	Id INT PRIMARY KEY,
	FirstName VARCHAR(30),
	MiddleName VARCHAR(30),
	LastName VARCHAR(30),
	JobTitle VARCHAR(30),
	DepartmentId INT,
	FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
	HireDate DATETIME,
	SALARY DECIMAL (15,2),
	AddressId INT
	FOREIGN KEY (AddressId) REFERENCES Addresses(Id),
)

INSERT INTO Employees VALUES
(1, 'Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '02/01/2013', 3500.00, NULL),
(2, 'Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '03/02/2004', 4000.00, NULL),
(3, 'Maria', 'Petrova', 'Ivanova', 'Intern', 5, '08/28/2016', 525.25, NULL),
(4, 'Georgi', 'Teziev', 'Ivanov', 'Sales', 2, '02/01/2013', 3000.00, NULL),
(5, 'Peter', 'Pan', 'Pan', 'Intern', 3, '08/28/2016', 599.88, NULL)

UPDATE Employees
SET SALARY = 3500.00
WHERE Id = 1
UPDATE Employees
SET SALARY = 4000.00
WHERE Id = 2
UPDATE Employees
SET SALARY = 525.25
WHERE Id = 3
UPDATE Employees
SET SALARY = 3000.00
WHERE Id = 4
UPDATE Employees
SET SALARY = 599.88
WHERE Id = 5

--19.
SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees

--20.
SELECT * FROM Towns
ORDER BY [Name] ASC
SELECT * FROM Departments
ORDER BY [Name] ASC
SELECT * FROM Employees
ORDER BY SALARY DESC

--21.
SELECT [Name] FROM Towns
ORDER BY [Name] ASC
SELECT [Name] FROM Departments
ORDER BY [Name] ASC
SELECT FirstName, LastName, JobTitle, SALARY FROM Employees
ORDER BY SALARY DESC

--22.
UPDATE Employees
SET SALARY *= 1.1

SELECT SALARY FROM Employees

USE Hotel
UPDATE Payments
SET TaxRate *= 0.97

SELECT TaxRate FROM Payments

USE Hotel
DELETE FROM Occupancies