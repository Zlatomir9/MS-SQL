--02.
SELECT * FROM Departments

--03.
SELECT [Name] FROM Departments

--04.
SELECT FirstName, LastName, SALARY FROM Employees

--05.
SELECT FirstName, MiddleName, LastName FROM Employees

--06.
SELECT FirstName + '.' + LastName + '@softuni.bg' FROM Employees AS Full_Email_Adress

--07.
SELECT DISTINCT SALARY FROM Employees

--08.
SELECT * FROM Employees WHERE JobTitle = 'Sales Representative'

--09.
SELECT FirstName, LastName, JobTitle FROM Employees WHERE SALARY >= 20000 AND SALARY <= 30000

--10.
SELECT FirstName + ' ' + MiddleName + ' ' + LastName 
FROM Employees 
AS Full_Name
WHERE SALARY = 25000 OR SALARY = 14000 OR SALARY = 12500 OR SALARY = 23600

--11.
SELECT FirstName, LastName
FROM Employees
WHERE ManagerID IS NULL

--12.
SELECT FirstName, LastName, SALARY 
FROM Employees
WHERE SALARY > 50000
ORDER BY SALARY DESC

--13.
SELECT TOP 5 FirstName, LastName
FROM Employees
ORDER BY SALARY DESC

--14.
SELECT FirstName, LastName FROM Employees
WHERE DepartmentId != 4

--15.
SELECT * FROM Employees
ORDER BY SALARY DESC, FirstName ASC, LastName DESC, MiddleName ASC

--16.
CREATE VIEW [V_EmployeesSalaries] AS
SELECT FirstName, LastName, SALARY
FROM Employees 

--17.
CREATE VIEW [V_EmployeeNameJobTitle] AS
SELECT FirstName + ' ' + COALESCE(MiddleName, '') + ' ' + LastName AS Full_Name, JobTitle
FROM Employees

--18.
SELECT DISTINCT JobTitle FROM Employees

--19.
SELECT TOP 10 * 
FROM Projects
WHERE StartDate <= GETDATE()
ORDER BY StartDate ASC, [Name] ASC

--20.
SELECT TOP 7 FirstName, LastName, HireDate
FROM Employees
ORDER BY HireDate DESC

--21.
UPDATE Employees
SET SALARY = SALARY * 1.12
WHERE DepartmentId = 1 OR DepartmentID = 2 OR DepartmentId = 4 OR DepartmentID = 11
SELECT SALARY FROM Employees

--22.
SELECT PeakName
FROM Peaks
ORDER BY PeakName ASC

--23.
SELECT TOP 30 CountryName, [Population]
FROM Countries
WHERE ContinentCode = 'EU'
ORDER BY [Population] DESC, CountryName ASC

--24.
SELECT CountryName, CountryCode,
	CASE 
		WHEN CurrencyCode = 'EUR' THEN 'Euro'
		ELSE 'Not Euro'
	END AS 'Currency'
FROM Countries
ORDER BY CountryName ASC

--25.
SELECT [Name] 
FROM Characters
ORDEr BY [Name] ASC