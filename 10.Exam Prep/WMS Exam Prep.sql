--01.
CREATE TABLE Clients(
ClientId INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
Phone CHAR(12) NOT NULL)

CREATE TABLE Mechanics(
MechanicId INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
[Address] NVARCHAR(255) NOT NULL)

CREATE TABLE Models(
ModelId INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) UNIQUE NOT NULL)

CREATE TABLE Jobs(
JobId INT PRIMARY KEY IDENTITY,
ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
[Status] NVARCHAR(11) NOT NULL DEFAULT 'Pending',
ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
IssueDate DATETIME NOT NULL,
FinishDate DATETIME,
CONSTRAINT CH_Status_Value CHECK([Status] IN ('Pending', 'In Progress', 'Finished')))

CREATE TABLE Orders(
OrderId INT PRIMARY KEY IDENTITY,
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
IssueDate DATETIME,
Delivered BIT DEFAULT 0)

CREATE TABLE Vendors(
VendorId INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) UNIQUE NOT NULL)

CREATE TABLE Parts(
PartId INT PRIMARY KEY IDENTITY,
SerialNumber NVARCHAR(50) UNIQUE NOT NULL,
[Description] NVARCHAR(255),
Price MONEY NOT NULL,
VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
StockQty INT NOT NULL DEFAULT 0,
CONSTRAINT CH_Price CHECK(Price > 0),
CONSTRAINT CH_Quantity CHECK(StockQty >= 0))

CREATE TABLE OrderParts(
OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
Quantity INT NOT NULL DEFAULT 1,
CONSTRAINT CH_Positive_Quantity CHECK(Quantity >= 1),
PRIMARY KEY (OrderId, PartId))

CREATE TABLE PartsNeeded(
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
Quantity INT NOT NULL DEFAULT 1,
CONSTRAINT CH_Positive_Part_Quantity CHECK(Quantity >= 1),
PRIMARY KEY (JobId, PartId))

--02.
INSERT INTO Clients VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts VALUES
('WP8182119', 'Door Boot Seal', 117.86, 2, 0),
('W10780048', 'Suspension Rod', 42.81, 1, 0),
('W10841140', 'Silicone Adhesive', 6.77, 4, 0),
('WPY055980', 'High Temperature Adhesive', 13.94, 3, 0)

--03.
UPDATE Jobs
SET MechanicId = 3
WHERE [Status] = 'Pending'

UPDATE Jobs
SET [Status] = 'In Progress'
WHERE MechanicId = 3 AND [Status] = 'Pending'
 
--04.
ALTER TABLE OrderParts WITH CHECK ADD CONSTRAINT [FK_OrderPart_Order] FOREIGN KEY(OrderId)
REFERENCES Orders (OrderId)
ON DELETE CASCADE

DELETE FROM Orders
WHERE OrderId = 19

--05.
SELECT FirstName + ' ' + LastName AS Mechanic,
	   j.[Status],
	   j.IssueDate
	FROM Mechanics m
	JOIN Jobs j ON m.MechanicId = j.MechanicId
  ORDER BY m.MechanicId, j.IssueDate, j.JobId

--06.
SELECT FirstName + ' ' + LastName AS Client,
	   DATEDIFF(DAY, j.IssueDate, '2017-04-24') AS [Days going],
	   j.[Status]
	FROM Clients c
	JOIN Jobs j ON c.ClientId = j.ClientId
	WHERE j.[Status] != 'Finished'
  ORDER BY [Days going] DESC

--07.
SELECT FirstName + ' ' + LastName AS Mechanic,
	   AVG(DATEDIFF(DAY, IssueDate, FinishDate)) AS [Average Days]
	FROM Mechanics m
	JOIN Jobs j ON m.MechanicId = j.MechanicId
  GROUP BY FirstName + ' ' + LastName, m.MechanicId
  ORDER BY m.MechanicId

--08.
SELECT FirstName + ' ' + LastName AS [Available]
	FROM Mechanics
	WHERE MechanicId NOT IN
	(SELECT m.MechanicId FROM Mechanics m
					 JOIN Jobs j ON m.MechanicId = j.MechanicId
					 WHERE j.[Status] = 'In Progress')
  ORDER BY MechanicId

--09.
SELECT j.JobId,
	   CASE
			WHEN SUM(p.Price * op.Quantity) IS NULL THEN 0
			ELSE SUM(p.Price * op.Quantity)
	   END AS Total
	FROM Jobs 
	FULL JOIN Orders o ON j.JobId = o.JobId
	FULL JOIN OrderParts op ON o.OrderId = op.OrderId
	FULL JOIN Parts p ON op.PartId = p.PartId
  WHERE j.[Status] = 'Finished'
  GROUP BY j.JobId
  ORDER BY Total DESC, j.JobId

10.
SELECT p.PartId, j.Status, p.Description
	FROM Parts p 
	JOIN OrderParts op ON p.PartId = op.PartId
	JOIN Orders o ON op.OrderId = o.OrderId
	JOIN Jobs j ON o.JobId = j.JobId
	JOIN PartsNeeded pn ON j.JobId = pn.JobId
	WHERE j.Status != 'Finished'

SELECT p.PartId,
	   p.[Description],
	   pn.Quantity AS [Required], 
	   p.StockQty AS [In Stock], 
	   CASE
           WHEN o.Delivered = 0 THEN op.Quantity
           ELSE 0
       END AS Ordered
	FROM Parts p 
	LEFT JOIN PartsNeeded pn ON pn.PartId = p.PartId
	LEFT JOIN OrderParts op ON op.PartId = p.PartId
	LEFT JOIN Jobs j ON j.JobId = pn.JobId
	LEFT JOIN Orders o ON o.JobId = j.JobId
	WHERE pn.Quantity > p.StockQty + CASE
										WHEN o.Delivered = 0 THEN op.Quantity
										ELSE 0
									  END
		  AND j.Status != 'Finished'
  ORDER BY p.PartId

--11.
CREATE PROC usp_PlaceOrder (@jobId INT, @partSerialNumber NVARCHAR(50), @quantity INT)
AS
BEGIN
	 IF((SELECT [Status] FROM Jobs WHERE @jobId = JobId) = 'Finished')
		THROW 50011, 'This job is not active!', 1
	 ELSE IF(@quantity <= 0)
		THROW 50012, 'Part quantity must be more than zero!', 1
	 ELSE IF((SELECT JobId FROM Jobs WHERE JobId = @jobId) IS NULL)
		THROW 50013, 'Job not found!', 1
	 ELSE IF((SELECT SerialNumber FROM Parts WHERE @partSerialNumber LIKE SerialNumber) IS NULL)
		THROW 50014, 'Part not found!', 1
	 IF((SELECT JobId FROM Orders WHERE @jobId = JobId AND IssueDate IS NULL) IS NULL)
	 BEGIN
		INSERT INTO Orders VALUES
		(@jobId, NULL, 0)
	 END

	 DECLARE @orderId INT = (SELECT TOP(1) OrderId FROM Orders WHERE JobId = @jobId AND IssueDate IS NULL)
	 DECLARE @partId INT = (SELECT PartId FROM Parts WHERE SerialNumber = @partSerialNumber)

	 IF((SELECT PartId FROM OrderParts WHERE PartId = @partId AND OrderId = @orderId) IS NULL)
		INSERT INTO OrderParts VALUES
		(@orderId, @partId, @quantity)
	 ELSE
		UPDATE OrderParts
		SET Quantity += @quantity
		WHERE PartId = @partId AND OrderId = @orderId
END

--12.
CREATE FUNCTION udf_GetCost (@jobId INT)
RETURNS DECIMAL(15, 2)
AS
BEGIN
	 DECLARE @Result DECIMAL (15, 2);
	 IF((SELECT TOP(1) OrderId FROM Orders WHERE JobId = @jobId) IS NULL)
	 BEGIN
		SET @Result = 0
		RETURN @Result
	 END
	 ELSE
		SET @Result = (SELECT SUM(p.Price) FROM Parts p
					   JOIN OrderParts op ON op.PartId = p.PartId
					   JOIN Orders o ON op.OrderId = o.OrderId
					   WHERE o.JobId = @jobId)
		RETURN @Result
END

SELECT dbo.udf_GetCost(1)