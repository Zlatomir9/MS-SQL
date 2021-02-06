--01.
CREATE TABLE Logs(
	LogId INT IDENTITY(1, 1) PRIMARY KEY,
	AccountId INT,
	OldSum MONEY,
	NewSum MONEY)

CREATE TRIGGER tr_AccountsUpdate ON Accounts FOR UPDATE
AS
BEGIN
	INSERT INTO Logs (AccountId, OldSum, NewSum)
		SELECT i.Id, d.Balance, i.Balance
		FROM inserted AS i
		JOIN deleted AS d ON i.Id = d.Id
		WHERE i.Balance != d.Balance
END

--02.
CREATE TABLE NotificationEmails(
Id INT IDENTITY(1, 1) PRIMARY KEY,
Recipient INT,
[Subject] VARCHAR(50),
Body TEXT

CREATE TRIGGER tr_LogsEmail ON Logs FOR INSERT
AS
BEGIN
	INSERT INTO NotificationEmails (Recipient, [Subject], Body)
	SELECT i.AccountId,
		   CONCAT('Balance change for account: ', i.AccountId),
		   CONCAT('On ', GETDATE(),' your balance was changed from ', i.NewSum, ' to ', i.OldSum)
	FROM inserted i
END

--03.
CREATE PROC usp_DepositMoney @AccountId INT, @MoneyAmount DECIMAL(15, 4)
AS
BEGIN TRANSACTION

DECLARE @account INT = (SELECT Id FROM Accounts WHERE Id = @AccountId)

IF (@account IS NULL)
BEGIN
	ROLLBACK
	RAISERROR('Invalid account id!', 16, 1)
	RETURN
END

IF (@MoneyAmount < 0)
BEGIN
	ROLLBACK
	RAISERROR('Negative amount!', 16, 1)
	RETURN
END

UPDATE Accounts
SET Balance += @MoneyAmount
WHERE Id = @AccountId
COMMIT

--04.
CREATE PROC usp_WithdrawMoney @AccountId INT, @MoneyAmount DECIMAL(15, 4)
AS
BEGIN TRANSACTION

DECLARE @account INT = (SELECT Id FROM Accounts WHERE Id = @AccountId)
DECLARE @accountBalance DECIMAL(15, 4) = (SELECT Balance FROM Accounts WHERE Id = @AccountId)

IF (@account IS NULL)
BEGIN
	ROLLBACK
	RAISERROR('Invalid account id!', 16, 1)
	RETURN
END

IF (@MoneyAmount < 0)
BEGIN
	ROLLBACK
	RAISERROR('Negative amount!', 16, 1)
	RETURN
END

IF (@accountBalance - @MoneyAmount < 0)
BEGIN
	ROLLBACK
	RAISERROR('Insufficient funds!', 16, 1)
	RETURN
END

UPDATE Accounts
SET Balance -= @MoneyAmount
WHERE Id = @AccountId
COMMIT

--05.
CREATE PROC usp_TransferMoney @SenderId INT, @ReceiverId INT, @Amount DECIMAL (15,4)
AS
BEGIN TRANSACTION
EXEC usp_WithdrawMoney @senderId, @Amount
EXEC usp_DepositMoney @ReceiverId, @Amount
COMMIT

SELECT * FROM Accounts WHERE Id = 1 OR Id = 2
EXEC usp_TransferMoney 2, 1, 354.23

--06.
SELECT *
	FROM Users u
	JOIN UsersGames ug ON ug.UserId = u.Id
	JOIN Games g ON g.Id = ug.GameId
  WHERE g.Name = 'Bali' AND u.Username IN ('baleremuda', 'loosenoise', 
				'inguinalself', 'buildingdeltoid', 'monoxidecos')

UPDATE UsersGames
 SET Cash += 50000
 WHERE GameId = (SELECT Id FROM Games WHERE Name = 'Bali') AND
       UserId IN (SELECT Id FROM Users WHERE UserName IN ('baleremuda', 'loosenoise', 
				'inguinalself', 'buildingdeltoid', 'monoxidecos'))

CREATE PROC usp_BuyItem @userId INT, @itemId INT, @gameId INT
AS
BEGIN TRANSACTION
DECLARE @user INT = (SELECT Id FROM Users WHERE Id = @userId)
DECLARE @item INT = (SELECT Id FROM Items WHERE Id = @itemId)

IF(@user IS NULL OR @item IS NULL)
BEGIN
	ROLLBACK
	RAISERROR('Invalid user or item id!', 16, 1)
	RETURN
END

DECLARE @userChash DECIMAL (15, 2) = (SELECT Cash FROM UsersGames WHERE UserId = @userId AND
		GameId = @gameId)

DECLARE @itemPrice DECIMAL (15, 2) = (SELECT Price FROM Items WHERE Id = @itemId)

IF(@userChash - @itemPrice < 0)
BEGIN
	ROLLBACK
	RAISERROR('Insufficient funds!', 16, 1)
	RETURN
END

UPDATE UsersGames
SET Cash -= @itemPrice
WHERE UserId = @userId AND GameId = @gameId

DECLARE @userGameId DECIMAL (15, 2) = (SELECT Id FROM UsersGames WHERE UserId = @userId AND
		GameId = @gameId)

INSERT INTO UserGameItems (ItemId, UserGameId) VALUES (@itemId, @gameId)

COMMIT

--07.
DECLARE @usersGameId INT = (SELECT Id FROM UsersGames WHERE UserId = 9 AND GameId = 87)

DECLARE @stamatCash DECIMAL(15,2) = (SELECT Cash 
	FROM UsersGames WHERE Id = @usersGameId)
DECLARE @itemsPrice DECIMAL(15,2) =	(SELECT SUM(Price) AS TotalPrice 
	FROM Items WHERE MinLevel BETWEEN 11 AND 12)	
IF(@stamatCash >= @itemsPrice)
BEGIN
	BEGIN TRANSACTION
	UPDATE UsersGames
	SET Cash -= @itemsPrice
	WHERE Id = @usersGameId

	INSERT INTO UserGameItems (ItemId, UserGameId)
	SELECT Id, @usersGameId FROM Items WHERE MinLevel BETWEEN 11 AND 12 
	COMMIT
END

SET @stamatCash = (SELECT Cash FROM UsersGames WHERE Id = @usersGameId)
SET @itemsPrice = (SELECT SUM(Price) AS TotalPrice FROM Items WHERE MinLevel BETWEEN 19 AND 21)

IF(@stamatCash >= @itemsPrice)
BEGIN
	BEGIN TRANSACTION
	UPDATE UsersGames
	SET Cash -= @itemsPrice
	WHERE Id = @usersGameId

	INSERT INTO UserGameItems (ItemId, UserGameId)
	SELECT Id, @usersGameId FROM Items WHERE MinLevel BETWEEN 19 AND 21 
	COMMIT
END

SELECT i.Name
	FROM Users u
	JOIN UsersGames ug ON ug.UserId = u.Id
	JOIN Games g ON g.Id = ug.GameId
	JOIN UserGameItems ugi ON ugi.UserGameId = ug.Id
	JOIN Items i ON i.Id = ugi.ItemId
  WHERE u.Username = 'Stamat' AND g.Name = 'Safflower'
  ORDER BY i.Name

--08.
CREATE PROC usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
BEGIN TRANSACTION
DECLARE @employee INT = (SELECT EmployeeID FROM Employees WHERE EmployeeID = @emloyeeId)
DECLARE @project INT = (SELECT ProjectID FROM Projects WHERE ProjectID = @projectID)
IF(@employee IS NULL OR @project IS NULL)
BEGIN
	ROLLBACK
	RAISERROR('Invalid employee or project id!', 16, 1)
	RETURN
END

DECLARE @employeeProjects INT = (SELECT COUNT(*) FROM EmployeesProjects 
									WHERE EmployeeID = @emloyeeId)

IF(@employeeProjects >= 3)
BEGIN
	ROLLBACK
	RAISERROR('The employee has too many projects!', 16, 2)
	RETURN
END

INSERT INTO EmployeesProjects (EmployeeId, ProjectId) 
	VALUES (@emloyeeId, @projectID)

COMMIT

--09.
CREATE TABLE Deleted_Employees
	(EmployeeId INT PRIMARY KEY, 
	 FirstName VARCHAR(50), 
	 LastName VARCHAR(50), 
	 MiddleName VARCHAR(50), 
	 JobTitle VARCHAR(50), 
	 DepartmentId INT, 
	 Salary DECIMAL (15,2))

CREATE TRIGGER tr_DeletedEmployees ON Employees FOR DELETE
AS
INSERT INTO Deleted_Employees (FirstName, LastName, MiddleName, JobTitle, 
	DepartmentId, Salary)
	SELECT FirstName, LastName, MiddleName, JobTitle, 
	DepartmentId, Salary FROM deleted 