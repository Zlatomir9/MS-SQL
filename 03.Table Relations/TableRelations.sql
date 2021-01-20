--01.
CREATE TABLE Persons
(PersonID INT NOT NULL,
FirstName VARCHAR(20) NOT NULL,
Salary DECIMAL(10,2),
PassportID INT NOT NULL)

CREATE TABLE Passports
(PassportID INT PRIMARY KEY,
PassportNumber VARCHAR(50))

INSERT INTO Persons VALUES
(1, 'Roberto', 43300.00, 102),
(2, 'Tom', 56100.00, 103),
(3, 'Yana', 60200.00, 101)

INSERT INTO Passports VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2')

ALTER TABLE Persons
ADD PRIMARY KEY (PersonID)

ALTER TABLE Persons
ADD FOREIGN KEY (PassportID) REFERENCES Passports(PassportID)

--02.
CREATE TABLE Models
(ModelID INT NOT NULL,
[Name] VARCHAR(30),
ManufacturerID INT NOT NULL)

CREATE TABLE Manufacturers
(ManufacturerID INT NOT NULL,
[Name] VARCHAR(30),
EstablishedOn DATETIME)

INSERT INTO Models VALUES
(101, 'X1', 1),
(102, 'i6', 1),
(103, 'Model S', 2),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3)

INSERT INTO Manufacturers VALUES
(1, 'BMW', 1916-03-07),
(2, 'Tesla', 2003-01-01),
(3, 'Lada', 1966-05-01)

ALTER TABLE Models
ADD PRIMARY KEY(ModelID)

ALTER TABLE Manufacturers
ADD PRIMARY KEY (ManufacturerID)

ALTER TABLE Models
ADD FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)

--03.
CREATE TABLE Students
(StudentID INT PRIMARY KEY,
[Name] VARCHAR(30))

INSERT INTO Students VALUES
(1, 'Mila'),
(2, 'Toni'),
(3, 'Ron')

CREATE TABLE Exams
(ExamID INT PRIMARY KEY,
[Name] VARCHAR(30))

INSERT INTO Exams VALUES
(101, 'SpringMVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g')

CREATE TABLE StudentsExams
(StudentID INT,  
ExamID INT,
  CONSTRAINT PK_StudentsExams
  PRIMARY KEY(StudentID, ExamID),
  CONSTRAINT FK_StudentsExams_Students
  FOREIGN KEY(StudentID)
  REFERENCES Students(StudentID),
  CONSTRAINT FK_StudentsExams_Exams
  FOREIGN KEY(ExamID)
  REFERENCES Exams(ExamID))

--04.
CREATE TABLE Teachers
(TeacherID INT PRIMARY KEY,
[Name] VARCHAR(50),
ManagerID INT)

INSERT INTO Teachers VALUES
(101, 'John', NULL),
(102, 'Maya', 106),
(103, 'Silvia', 106),
(104, 'Ted', 105),
(105, 'Mark', 101),
(106, 'Greta', 101)

ALTER TABLE Teachers
ADD FOREIGN KEY (ManagerID) REFERENCES Teachers(TeacherID)

--05.
CREATE DATABASE OnlineStore

CREATE TABLE ItemTypes
(ItemTypeID INT PRIMARY KEY,
[Name] VARCHAR(50))

CREATE TABLE Items
(ItemID INT PRIMARY KEY,
[Name] VARCHAR(50),
ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID))

CREATE TABLE Cities
(CityID INT PRIMARY KEY,
[Name] VARCHAR(50))

CREATE TABLE Customers
(CustomerID INT PRIMARY KEY,
[Name] VARCHAR(50),
Birthday DATETIME,
CityID INT FOREIGN KEY REFERENCES Cities(CityID))

CREATE TABLE Orders
(OrderID INT PRIMARY KEY,
CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID))

CREATE TABLE OrderItems
(OrderID INT,  
ItemID INT,
  CONSTRAINT PK_OrderItems
  PRIMARY KEY(OrderID, ItemID),
  CONSTRAINT FK_OrderItems_Orders
  FOREIGN KEY(OrderID)
  REFERENCES Orders(OrderID),
  CONSTRAINT FK_StudentsExams_Items
  FOREIGN KEY(ItemID)
  REFERENCES Items(ItemID))

--06.
CREATE DATABASE University

CREATE TABLE Majors
(MajorID INT PRIMARY KEY,
[Name] VARCHAR(50))

CREATE TABLE Students
(StudentID INT PRIMARY KEY,
StudentNumber INT,
StudentName VARCHAR(50),
MajorID INT FOREIGN KEY REFERENCES Majors (MajorID))

CREATE TABLE Payments
(PaymentID INT PRIMARY KEY,
PaymentDate DATETIME,
PaymentAmount DECIMAL(10,2),
StudentID INT FOREIGN KEY REFERENCES Students (StudentID))

CREATE TABLE Subjects
(SubjectID INT PRIMARY KEY,
SubjectName VARCHAR(50))

CREATE TABLE Agenda
(StudentID INT,
SubjectID INT
  CONSTRAINT PK_Agenda
  PRIMARY KEY(StudentID, SubjectID),
  CONSTRAINT FK_Agenda_Students
  FOREIGN KEY(StudentID)
  REFERENCES Students(StudentID),
  CONSTRAINT FK_StudentsExams_Subjects
  FOREIGN KEY(SubjectID)
  REFERENCES Subjects(SubjectID))

--09.
SELECT m.MountainRange, p.PeakName, p.Elevation 
    FROM Mountains AS m
    JOIN Peaks As p ON p.MountainId = m.Id
   WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC