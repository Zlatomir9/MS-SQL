--01.
SELECT TOP (5) EmployeeID, JobTitle, e.AddressID, AddressText
	FROM Employees AS e
	JOIN Addresses AS a
	ON e.AddressID = a.AddressID
   ORDER BY a.AddressID

--02.
SELECT TOP(50) FirstName, LastName, Name, AddressText 
	FROM Employees AS e
	JOIN Addresses AS a
	ON e.AddressID = a.AddressID
	JOIN Towns AS t
	ON t.TownID = a.TownID
   ORDER BY FirstName, LastName

--03.
SELECT EmployeeID, FirstName, LastName, d.Name AS DepartamentName
	FROM Employees e
	JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
	WHERE d.Name = 'Sales'
	ORDER BY EmployeeID

--04.
SELECT TOP(5) EmployeeID, FirstName, Salary, d.Name AS DepartamentName 
	FROM Employees e
	JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
	WHERE e.Salary > 15000
  ORDER BY e.DepartmentID

--05.
SELECT TOP(3) e.EmployeeID, FirstName 
	FROM Employees e
	LEFT JOIN EmployeesProjects ep
	ON e.EmployeeID = ep.EmployeeID
	WHERE ep.EmployeeID IS NULL
  ORDER BY e.EmployeeID

--06.
SELECT FirstName, LastName, HireDate, d.Name AS DeptName
	FROM Employees e
	JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
	WHERE e.HireDate > 1999-01-01 
	AND	d.Name IN ('Sales', 'Finance')
	ORDER BY e.HireDate

--07.
SELECT TOP (5) e.EmployeeID, FirstName, p.Name AS ProjectName
	FROM Employees e
	JOIN EmployeesProjects ep
	ON e.EmployeeID = ep.EmployeeID
	JOIN Projects p
	ON p.ProjectID = ep.ProjectID
	WHERE p.StartDate > 2002-08-13 AND p.EndDate IS NULL
	ORDER BY e.EmployeeID

--08.
SELECT e.EmployeeID, FirstName, 
	CASE 
		WHEN DATEPART(YEAR, p.StartDate) < 2005
		THEN p.Name
		ELSE NULL
	END AS ProjectName
	FROM Employees e
	JOIN EmployeesProjects ep
	ON e.EmployeeID = ep.EmployeeID
	JOIN Projects p
	ON ep.ProjectID = p.ProjectID
	WHERE e.EmployeeID = 24

--09.
SELECT e.EmployeeID, e.FirstName, e.ManagerID, m.FirstName AS ManagerName
	FROM Employees e
	JOIN Employees m
	ON e.ManagerID = m.EmployeeID
	WHERE e.ManagerID IN (3, 7)
  ORDER BY e.EmployeeID

--10.
SELECT TOP(50) 
	   e.EmployeeID,
	   e.FirstName + ' ' + e.LastName AS EmployeeName,
	   m.FirstName + ' ' + m.LastName AS ManagerName,
	   d.Name AS DepartmentName
	FROM Employees e
	JOIN Employees m
	ON e.ManagerID = m.EmployeeID
	JOIN Departments d
	ON e.DepartmentID = d.DepartmentID
  ORDER BY e.EmployeeID

--11.
SELECT TOP(1)
(SELECT AVG(Salary) FROM Employees e
	WHERE e.DepartmentID = d.DepartmentID)
		AS AverageSalary
	FROM Departments d
	WHERE (SELECT COUNT(*) FROM Employees e WHERE e.DepartmentID = d.DepartmentID) > 0
	ORDER BY AverageSalary