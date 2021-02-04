--08.
CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
ALTER TABLE Departments
ALTER COLUMN ManagerID INT NULL

DELETE FROM EmployeesProjects
WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

UPDATE Employees
	SET ManagerID = NULL
  WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

UPDATE Employees
	SET ManagerID = NULL
  WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

UPDATE Departments
	SET ManagerID = NULL
  WHERE DepartmentID = @departmentId

DELETE FROM Employees
	WHERE DepartmentID = @departmentId

DELETE FROM Departments
	WHERE DepartmentID = @departmentId

SELECT COUNT(*) FROM Employees
	WHERE DepartmentID = @departmentId

--13.
CREATE FUNCTION ufn_CashInUsersGames(@gameName VARCHAR(MAX))
RETURNS TABLE
AS
	RETURN (SELECT SUM(r.TotalCash) AS TotalCash
	FROM (SELECT Cash AS TotalCash,
			ROW_NUMBER() OVER (ORDER BY Cash DESC) AS RowNumber
		  FROM Games g
		  JOIN UsersGames ug ON ug.GameId = g.Id
		  WHERE Name = @gameName) AS r
	WHERE r.RowNumber % 2 = 1)

SELECT * FROM ufn_CashInUsersGames('Love in a mist')