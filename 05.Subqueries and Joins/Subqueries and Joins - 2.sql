--12.
SELECT c.CountryCode, MountainRange, PeakName, Elevation
	FROM Countries c
	JOIN MountainsCountries mc
	ON c.CountryCode = mc.CountryCode
	JOIN Mountains m
	ON m.Id = mc.MountainId
	JOIN Peaks p
	ON p.MountainId = m.Id
	WHERE c.CountryCode = 'BG'
	AND p.Elevation > 2835
	ORDER BY p.Elevation DESC
	 
--13.
SELECT c.CountryCode, COUNT(*) AS MountainRanges
	FROM Countries c
	JOIN MountainsCountries mc
	ON c.CountryCode = mc.CountryCode
	JOIN Mountains m
	ON m.Id = mc.MountainId
	WHERE c.CountryName IN ('Bulgaria', 'Russia', 'United States')
	GROUP BY c.CountryCode

--14.
SELECT TOP (5) c.CountryName, r.RiverName
	FROM Countries c
	LEFT JOIN CountriesRivers cr
	ON c.CountryCode = cr.CountryCode
	LEFT JOIN Rivers r
	ON r.Id = cr.RiverId
	WHERE c.ContinentCode IN ('AF')
	ORDER BY c.CountryName

--15.
SELECT sorted.ContinentCode, sorted.CurrencyCode, sorted.CurrencyUsage
	FROM Continents ct
	JOIN (SELECT c.ContinentCode AS ContinentCode,
		  COUNT(c.CurrencyCode) AS CurrencyUsage,
	      CurrencyCode as CurrencyCode,
	      DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY COUNT(CurrencyCode) DESC) AS [Rank]
	      FROM Countries c
	      GROUP BY ContinentCode, CurrencyCode
	      HAVING COUNT(CurrencyCode) > 1)
	AS sorted
	ON ct.ContinentCode = sorted.ContinentCode
	WHERE sorted.Rank = 1

--16.
SELECT COUNT(*) AS [Count]
	FROM Countries c
	LEFT JOIN MountainsCountries mc
	ON c.CountryCode = mc.CountryCode
	LEFT JOIN Mountains m
	ON m.Id = mc.MountainId
	WHERE mc.MountainId IS NULL
	GROUP BY mc.MountainId

--17.
SELECT TOP (5)
  c.CountryName, 
  MAX(p.Elevation) AS HighestPeakElevation, 
  MAX(r.Length) AS LongestRiverLength
	FROM Countries c
	FULL JOIN MountainsCountries mc
	ON c.CountryCode = mc.CountryCode
	FULL JOIN Mountains m
	ON m.Id = mc.MountainId
	FULL JOIN Peaks p
	ON m.Id = p.MountainId
	FULL JOIN CountriesRivers cr
	ON c.CountryCode = cr.CountryCode
	FULL JOIN Rivers r
	ON r.Id = cr.RiverId
	GROUP BY c.CountryName
  ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName

--18.
SELECT TOP(5) Country, 
	   CASE
			WHEN PeakName IS NULL THEN '(no highest peak)'
			ELSE PeakName
	   END AS [Highest Peak Name],
	   CASE
			WHEN Elevation IS NULL THEN 0
			ELSE Elevation
	   END AS [Highest Peak Elevation],
	   CASE
			WHEN MountainRange IS NULL THEN '(no mountain)'
			ELSE MountainRange
	   END AS [Mountain]
	 FROM (SELECT *,
		DENSE_RANK () OVER
		(PARTITION BY [Country] ORDER BY [Elevation] DESC) AS [PeakRank]
		   FROM(
				SELECT CountryName AS [Country],
					   p.PeakName,
					   p.Elevation,
					   m.MountainRange
				FROM Countries c
				LEFT JOIN MountainsCountries mc
				ON c.CountryCode = mc.CountryCode
				LEFT JOIN Mountains m
				ON m.Id = mc.MountainId
				LEFT JOIN Peaks p
				ON p.MountainId = m.Id) AS [Info]
		 ) AS [PeakRanks]
	WHERE [PeakRank] = 1