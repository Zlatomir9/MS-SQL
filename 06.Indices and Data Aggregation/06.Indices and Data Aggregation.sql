--01.
SELECT COUNT(*) AS Count
	FROM WizzardDeposits

--02.
SELECT TOP(1) MagicWandSize AS LongestMagicWand
	FROM WizzardDeposits
	ORDER BY MagicWandSize DESC

--03.
SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand
	FROM WizzardDeposits
	GROUP BY DepositGroup

--04.
SELECT TOP (2) DepositGroup
	FROM WizzardDeposits
	GROUP BY DepositGroup
	ORDER BY AVG(MagicWandSize)

--05.
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
	GROUP BY DepositGroup

--06.
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
	GROUP BY DepositGroup, MagicWandCreator
	HAVING MagicWandCreator = 'Ollivander family'

--07.
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
	GROUP BY DepositGroup, MagicWandCreator
	HAVING MagicWandCreator = 'Ollivander family' AND SUM(DepositAmount) < 150000
	ORDER BY TotalSum DESC

--08.
SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge
	FROM WizzardDeposits
	GROUP BY DepositGroup, MagicWandCreator
	ORDER BY MagicWandCreator, DepositGroup

--09.
SELECT 
	CASE
		WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
		WHEN Age >= 61 THEN '[61+]'
	END AS [AgeGroup],
		COUNT(*) AS [WizardCount]
	FROM WizzardDeposits AS wd
GROUP BY 
	CASE
		WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
		WHEN Age >= 61 THEN '[61+]'
	END

--10.
SELECT SUBSTRING(FirstName, 1, 1) AS FirstLetter
	FROM WizzardDeposits
	WHERE DepositGroup = 'Troll Chest'
	GROUP BY SUBSTRING(FirstName, 1, 1)
	ORDER BY FirstLetter

--11.
SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS 'AverageInterest' 
	FROM WizzardDeposits
	WHERE DepositStartDate > '1985-01-01'
	GROUP BY DepositGroup, IsDepositExpired
	ORDER BY DepositGroup DESC, IsDepositExpired ASC

--12.
SELECT ABS(SUM(SumDifference)) 
	FROM 
	(SELECT LEAD(DepositAmount) OVER (ORDER BY Id) - DepositAmount AS SumDifference
	FROM WizzardDeposits) as d

--13.
SELECT DepartmentID, SUM(Salary) AS TotalSalary
	FROM Employees
	GROUP BY DepartmentID
	ORDER BY DepartmentID

--14.
SELECT DepartmentID, MIN(Salary) AS MinimumSalary
	FROM Employees
	WHERE DepartmentID IN (2, 5, 7) AND HireDate > '2000-01-01'
	GROUP BY DepartmentID

--15.
SELECT *
	INTO EmployeesAverageSalary
	FROM Employees
	WHERE Salary > 30000

DELETE FROM EmployeesAverageSalary
	WHERE ManagerID = 42

UPDATE EmployeesAverageSalary
	SET Salary += 5000
	WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary)
	FROM EmployeesAverageSalary
	GROUP BY DepartmentID

--16.
SELECT DepartmentID, MAX(Salary) AS MaxSalary
	FROM Employees
	GROUP BY DepartmentID
	HAVING MAX(Salary) < 30000 OR MAX(Salary) > 70000

--17.
SELECT COUNT(Salary) AS Count
	FROM Employees
	WHERE ManagerID IS NULL

--18.
SELECT DepartmentID, ThirdHighestSalary 
	FROM
	(SELECT DepartmentID, Salary AS ThirdHighestSalary,
		DENSE_RANK () OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS Ranked
		FROM Employees
		GROUP BY DepartmentID, Salary) AS d
	WHERE Ranked = 3

--19.
SELECT TOP(10) FirstName, LastName, e.DepartmentID FROM Employees e,	
	(SELECT DepartmentID, AVG(Salary) AS AverageSalary
	FROM Employees
	GROUP BY DepartmentID) AS d
	WHERE e.Salary > d.AverageSalary AND e.DepartmentID = d.DepartmentID
	ORDER BY e.DepartmentID