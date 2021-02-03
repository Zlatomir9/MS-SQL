--01.
CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
	SELECT FirstName, LastName
		FROM Employees
	  WHERE Salary > 35000

--02.
CREATE PROC usp_GetEmployeesSalaryAboveNumber @Num DECIMAL(18,4)
AS
	SELECT FirstName, LastName
		FROM Employees
	  WHERE Salary >= @Num

EXEC usp_GetEmployeesSalaryAboveNumber @Num = 48100

--03.
CREATE PROC usp_GetTownsStartingWith @String NVARCHAR(MAX)
AS
	SELECT [Name]
		FROM Towns
	  WHERE [Name] LIKE CONCAT(@String, '%')

EXEC usp_GetTownsStartingWith @String = sa

--04.
CREATE PROC usp_GetEmployeesFromTown @TownName NVARCHAR(MAX)
AS
	SELECT FirstName, LastName
		FROM Employees e
	  JOIN Addresses a ON e.AddressID = a.AddressID
	  JOIN Towns t ON t.TownID = a.TownID
	WHERE t.[Name] = @TownName

EXEC usp_GetEmployeesFromTown @TownName = 'Sofia'

--05.
CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18,4))
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @SalaryLevel NVARCHAR(MAX);
		IF(@Salary < 30000)
			SET @SalaryLevel = 'Low'
		ELSE IF(@Salary BETWEEN 30000 AND 50000)
			SET @SalaryLevel = 'Average'
		ELSE IF(@Salary > 50000)
			SET @SalaryLevel = 'High'
	  RETURN @SalaryLevel;
	END

SELECT FirstName, Salary, dbo.ufn_GetSalaryLevel(Salary)
	FROM Employees

--06.
CREATE PROC usp_EmployeesBySalaryLevel @SalaryLevel NVARCHAR(MAX)
	AS
		SELECT FirstName, LastName
			FROM Employees
			WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel

EXEC usp_EmployeesBySalaryLevel @SalaryLevel = 'high'

--07.
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX))
RETURNS BIT
AS
  BEGIN
	 DECLARE @Index INT = 1
     WHILE(LEN(@word) >= @Index)
		  BEGIN
		  DECLARE @Letter VARCHAR(1) = SUBSTRING(@word, @Index, 1)
			IF(CHARINDEX(@Letter, @setOfLetters) > 0)
		   	   SET @Index += 1
			ELSE
				RETURN 0
		  END
	  RETURN 1
  END

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')

--09.
CREATE PROC usp_GetHoldersFullName
AS
	SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name]
		FROM AccountHolders

EXEC usp_GetHoldersFullName

--10.
CREATE PROC usp_GetHoldersWithBalanceHigherThan @Number MONEY
AS
	SELECT FirstName, LastName
		FROM AccountHolders ah
		JOIN Accounts a ON ah.Id = a.AccountHolderId
		GROUP BY FirstName, LastName
		HAVING SUM(Balance) > @Number
	  ORDER BY FirstName, LastName

--11.
CREATE FUNCTION ufn_CalculateFutureValue(@InitialSum DECIMAL(18,4), 
										 @YearlyInterestRate FLOAT, 
										 @NumberOfYears INT)
RETURNS DECIMAL (18,4)
AS
	BEGIN
	  RETURN @InitialSum * POWER((1 + @YearlyInterestRate), @NumberOfYears)
	END

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

--12.
CREATE PROC usp_CalculateFutureValueForAccount(@AccountId INT, @YearlyInterestRate FLOAT)
AS
	SELECT a.Id AS [Account Id], 
		   FirstName, 
		   LastName, 
		   Balance AS [Current Balance], 
		   dbo.ufn_CalculateFutureValue(Balance, @YearlyInterestRate, 5) AS [Balance in 5 years]
		FROM AccountHolders ah
		JOIN Accounts a ON ah.Id = a.AccountHolderId
		WHERE a.Id = @AccountId

EXEC usp_CalculateFutureValueForAccount 1, 0.1