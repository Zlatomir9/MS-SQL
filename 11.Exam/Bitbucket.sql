CREATE TABLE Users
(
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) NOT NULL,
[Password] VARCHAR(30) NOT NULL,
Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
RepositoryId INT NOT NULL REFERENCES Repositories(Id),
ContributorId INT NOT NULL REFERENCES Users(Id)
PRIMARY KEY(RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
Id INT PRIMARY KEY IDENTITY,
Title VARCHAR(255) NOT NULL,
IssueStatus CHAR(6) NOT NULL,
RepositoryId INT NOT NULL REFERENCES Repositories(Id),
AssigneeId INT NOT NULL REFERENCES Users(Id)
)

CREATE TABLE Commits
(
Id INT PRIMARY KEY IDENTITY,
[Message] VARCHAR(255) NOT NULL,
IssueId INT REFERENCES Issues(Id),
RepositoryId INT NOT NULL REFERENCES Repositories(Id),
ContributorId INT NOT NULL REFERENCES Users(Id)
)

CREATE TABLE Files
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
Size DECIMAL(18,2) NOT NULL,
ParentId INT REFERENCES Files(Id),
CommitId INT NOT NULL REFERENCES Commits(Id)
)

--02.
INSERT INTO Files (Name, Size, ParentId, CommitId) VALUES
('Trade.idk',	2598.0,	1,	1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json', 14034.87, 3, 6),
('Operate.xix', 7662.92, 7, 7)

INSERT INTO Issues (Title, IssueStatus, RepositoryId, AssigneeId) VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)

--03.
UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

--04.
ALTER TABLE RepositoriesContributors
   ADD CONSTRAINT FK_Repositor_Repos
   FOREIGN KEY (RepositoryId) REFERENCES Repositories(Id) ON DELETE CASCADE

DELETE FROM RepositoriesContributors
WHERE RepositoryId = 3

ALTER TABLE Issues
   ADD CONSTRAINT FK_Issues_Reposito_3E52440B
   FOREIGN KEY (RepositoryId) REFERENCES Repositories(Id) ON DELETE CASCADE

DELETE FROM Issues
WHERE RepositoryId = 3

--05.
SELECT Id, Message, RepositoryId, ContributorId
	FROM Commits
  ORDER BY Id, Message, RepositoryId, ContributorId

--06.
SELECT Id, Name, Size
	FROM Files
	WHERE Size > 1000 AND Name LIKE '%html'
  ORDER BY Size DESC, Id, Name

--07.
SELECT i.Id,
	   CONCAT(u.Username, ' : ', i.Title) AS IssueAssignee
	FROM Issues i
	JOIN Users u ON i.AssigneeId = u.Id
  ORDER BY i.Id DESC, IssueAssignee

--08.
SELECT Id, Name, CONCAT(Size, 'KB')
	FROM Files
  WHERE Id NOT IN (SELECT DISTINCT ParentId
						 FROM Files
						 WHERE ParentId IS NOT NULL)

--09.
SELECT TOP(5) r.Id, Name, COUNT(*) AS Commits
	FROM RepositoriesContributors rc
	JOIN Repositories r ON r.Id = rc.RepositoryId
	JOIN Commits c ON r.Id = c.RepositoryId
	GROUP BY r.Id, Name
	ORDER BY Commits DESC, Id, Name

--10.
SELECT u.Username, AVG(f.Size) AS Size
	FROM Users u
	JOIN Commits c ON u.Id = c.ContributorId
	JOIN Files f ON f.CommitId = c.Id
  GROUP BY u.Username
  ORDER BY Size DESC, u.Username

--11.
CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS
BEGIN
	 DECLARE @commitsCount INT;
	 SET @commitsCount = (SELECT COUNT(c.Id)
								FROM Commits c
								JOIN Users u ON c.ContributorId = u.Id
								WHERE u.Username = @username)

	RETURN @commitsCount;
END

SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

--12.
CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(100))
AS
	SELECT Id, Name, CONCAT(Size, 'KB')
		FROM Files
		WHERE Name LIKE CONCAT('%', @fileExtension)
	  ORDER BY Id, Name, Size DESC

EXEC usp_SearchForFiles 'txt'