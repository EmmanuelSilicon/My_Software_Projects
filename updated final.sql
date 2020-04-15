-----------------------------New Project Ltd.-----------------------------------------------------------------------------	
/* Question 1 */
create database TimeCard

/* Question 2 */
CREATE SCHEMA Payment
CREATE SCHEMA ProjectDetails
CREATE SCHEMA CustomerDetails
CREATE SCHEMA HumanResources

/* Question 3 & 4 & 5 */
CREATE TABLE CustomerDetails.Clients (
ClientID int PRIMARY KEY IDENTITY (1,1),
CompanyName VARCHAR (40) NOT NULL,
Address VARCHAR (50) NOT NULL,
City VARCHAR (30) NOT NULL,
State VARCHAR (30) NOT NULL,
Zip VARCHAR (40) NOT NULL,
Country VARCHAR (30) NOT NULL,
ContactPerson VARCHAR (20) NOT NULL,
Phone VARCHAR (100) NOT NULL check ( Phone like '[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]')
)

CREATE TABLE HumanResources.Employees (
EmployeeID INT PRIMARY KEY IDENTITY (1,1),
FirstName VARCHAR (30) NOT NULL,
LastName VARCHAR (30) ,
Title VARCHAR (40) NOT NULL CHECK (Title IN('Trainee', 'Team Member', 'Team Leader', 'Project Manager',
'Senior Project Manager')),
Phone VARCHAR (100) NOT NULL CHECK (Phone LIKE '[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]') ,
BillingRate MONEY  UNIQUE ,
CHECK (BillingRate > 0)
)


CREATE TABLE ProjectDetails.Projects (
ProjectID INT PRIMARY KEY IDENTITY (1,1),
ProjectName VARCHAR (50),
ProjectDescription VARCHAR (100),
ClientID INT FOREIGN KEY REFERENCES CustomerDetails.Clients (ClientID) ,
BillingEstimate MONEY 
CHECK (BillingEstimate > 1000),
EmployeeID INT FOREIGN KEY REFERENCES HumanResources.Employees (EmployeeID),
StartDate datetime  NOT NULL  UNIQUE,
EndDate DATETIME NOT NULL UNIQUE,
CHECK (EndDate > StartDate)
)

CREATE TABLE Payment.PaymentMethod (
PaymentMethodID INT PRIMARY KEY IDENTITY (1,1),
Description VARCHAR (100) NOT NULL 
)

CREATE TABLE Payment.Payments (
PaymentID INT PRIMARY KEY IDENTITY (1,1 ),
ProjectID INT FOREIGN KEY REFERENCES ProjectDetails.Projects (ProjectID),
PaymentAmount MONEY,
Constraint chkAmount CHECK (PaymentAmount > 0),
PaymentDate DateTime,
CHECK (PaymentDate > EndDate),  
EndDate DATETIME FOREIGN KEY REFERENCES ProjectDetails.Projects (EndDate),
CreditCardNumber INT ,
CardHoldersName VARCHAR (40),
CreditCardExpiryDate DateTime,
Constraint chkExpDate CHECK (CreditCardExpiryDate > PaymentDate),
PaymentMethodID INT FOREIGN KEY REFERENCES Payment.PaymentMethod (PaymentMethodID) ,
PaymentDue MONEY,
CHECK (PaymentDue < PaymentAmount),
)

CREATE TABLE ProjectDetails.WorkCodes (
WorkCodeID INT PRIMARY KEY IDENTITY (1,1 ),
Description VARCHAR (100) NOT NULL
)

CREATE TABLE ProjectDetails.ExpenseDetails (
ExpenseCodeID INT PRIMARY KEY IDENTITY (1,1 ),
Description VARCHAR (100) NOT NULL 
)

CREATE TABLE ProjectDetails.TimeCards(
TimeCardID INT PRIMARY KEY IDENTITY (1,1),
EmployeeID INT FOREIGN KEY REFERENCES HumanResources.Employees (EmployeeID),
DateIssued DATETIME,
CHECK (DateIssued > getdate() AND DateIssued > StartDate),
StartDate DateTime FOREIGN KEY REFERENCES ProjectDetails.Projects (StartDate),
DaysWorked INT,
CHECK (DaysWorked > 0),
ProjectID INT FOREIGN KEY REFERENCES ProjectDetails.Projects (ProjectID),
BillableHours INT,
CHECK (BillableHours > 0),
BillingRate MONEY FOREIGN KEY REFERENCES HumanResources.Employees (BillingRate),
TotalCost AS BillableHours * BillingRate,
WorkCodeID INT FOREIGN KEY REFERENCES ProjectDetails.WorkCodes (WorkCodeID),
TimeCardDetailID INT,
WorkDescription VARCHAR (100)  Unique NOT NULL 
)

CREATE TABLE ProjectDetails.TimeCardExpenses(
TimeCardExpensesID INT PRIMARY KEY IDENTITY (1,1),
TimeCardID INT FOREIGN KEY REFERENCES ProjectDetails.TimeCards (TimeCardID),
ExpenseDate DATETIME NOT NULL,
EndDate DATETIME FOREIGN KEY REFERENCES ProjectDetails.Projects (EndDate),
CHECK (ExpenseDate < EndDate),
ExpenseAmount MONEY,
CHECK (ExpenseAmount > 0),
ProjectID INT FOREIGN KEY REFERENCES ProjectDetails.Projects (ProjectID),
ExpenseID INT FOREIGN KEY REFERENCES ProjectDetails.ExpenseDetails (ExpenseCodeID)
)


/* Question 6 */
C:\Users\HP\Desktop\sql files\sql project\PaymentDetails.txt

/* Question 7 */
CREATE NONCLUSTERED INDEX IDX_Emp
ON HumanResources.Employees (FirstName,LastName)

CREATE NONCLUSTERED INDEX IDX_Expense
ON ProjectDetails.TimeCardExpenses (TimeCardID)

create view HumanResources.vwEmployeeProjectDetails with schemabinding
as
SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName as 'Employee Name',p.ProjectName FROM HumanResources.Employees e
JOIN ProjectDetails.Projects p ON e.EmployeeID = p.EmployeeID

create unique clustered index idx_vwEmployeeProjectDetails
on HumanResources.vwEmployeeProjectDetails (EmployeeID)

create view ProjectDetails.vwDueProjects with schemabinding
as
SELECT ProjectID,ProjectName,ProjectDescription,StartDate,EndDate FROM ProjectDetails.Projects


create unique clustered index idx_vwDueProjects
on ProjectDetails.vwDueProjects (ProjectID)

/* Question 8 */
SELECT p.ProjectID as 'Project ID',p.ProjectName'PROJECT Name',e.FirstName + ' '+ e.LastName as 'Employee Name',
 e.Title as 'Employee Title' FROM HumanResources.Employees e JOIN ProjectDetails.Projects p
 ON e.EmployeeID = p.EmployeeID

C:\Users\HP\Desktop\sql files\sql project\Report Project2\Report Project2.sln

/* Question 9 */
 USE [master]
GO
CREATE LOGIN [John] WITH PASSWORD=N'12345' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
USE [TimeCard]
GO
CREATE USER [John] FOR LOGIN [John]
GO
USE [TimeCard]
GO
ALTER ROLE [db_datareader] ADD MEMBER [John]
GO
USE [TimeCard]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [John]
GO

USE [master]
GO
CREATE LOGIN [Samantha] WITH PASSWORD=N'12345' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
USE [TimeCard]
GO
CREATE USER [Samantha] FOR LOGIN [Samantha]
GO
USE [TimeCard]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Samantha]
GO
USE [TimeCard]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Samantha]
GO

USE [master]
GO
CREATE LOGIN [Sam] WITH PASSWORD=N'12345' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
USE [TimeCard]
GO
CREATE USER [Sam] FOR LOGIN [Sam]
GO
USE [TimeCard]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [Sam]
GO
USE [TimeCard]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [Sam]
GO
USE [TimeCard]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [Sam]
GO


/* Question 10 */
create master key encryption by password = 'masterkey'
select * from sys.master_key_passwords  

use TimeCard
go
create certificate Credit_card_number
with subject='Credit Card Number';
go

create symmetric key symmetrickey_2
with algorithm = AES_256
encryption by certificate Credit_card_number;
go

open symmetric key symmetrickey_2
decryption by certificate Credit_card_number
go


/* Question 11*/
BACKUP DATABASE [TimeCard] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL12.IT_EMMANUEL\MSSQL\Backup\TimeCard.bak' WITH NOFORMAT, NOINIT,  NAME = N'TimeCard-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

------------------------------------INSERTING INTO TABLES-----------------------------------------------------------------------------------
INSERT INTO CustomerDetails.Clients
	VALUES ('Dangote Cement','Tony Close', 'Agege', 'Lagos', '100030', 'Nigeria','John', '01-020-5877-383-435'),
	       ('Chemioron','Ogba', 'Ikeja', 'Lagos', '100030', 'Nigeria','Femi', '01-020-4365-887-223'),
	       ('Faro','Girei', 'Yola', 'Adamawa', '102001', 'Nigeria','Tope', '01-050-4665-223-123'),
	       ('Nestle Nigeria Plc','Ajayi', 'Ikeja', 'Lagos', '100030', 'Nigeria','Azeez', '01-020-3278-555-234'),
	       ('Nigerian Breweries Plc','James way', 'Apapa', 'Lagos', '100030', 'Nigeria','Zainab', '01-020-1352-636-867')
	SELECT * FROM CustomerDetails.Clients


INSERT INTO HumanResources.Employees
	VALUES('Azeez','Lawal','Trainee','01-050-6753-321-479', 50000),
	      ('Femi','Ajayi','Team Member','01-050-1342-156-734', 70000),
	      ('Zainab','Abubakar','Team Leader','01-050-2311-165-556', 100000),
	      ('John','Mark','Project Manager','01-020-5899-077-844', 150000),
	      ('Tope','Ayomilesi','Senior Project Manager','01-020-6746-363-543', 250000)
SELECT * FROM HumanResources.Employees

INSERT INTO ProjectDetails.Projects
Values('Web Development', 'Frontend',1,5000,1,'2019-01-14','2019-08-19'),
      ('Web Development', 'Backend',1,7000,1,'2019-04-20','2019-09-11'),
	  ('Game', 'Bubbles',2,6000,2,'2019-03-21','2019-08-12'),
	  ('Software development', 'ATM',2, 9000,2,'2019-02-15','2019-10-17'),
	  ('Database', 'Registration',3,8000,3,'2019-01-16','2019-09-18'),
      ('Game','Barbie',4,4000,4,'2019-05-24','2019-07-21')

SELECT * FROM ProjectDetails.Projects

INSERT INTO Payment.PaymentMethod 
VALUES('Cash'),
	  ('P.O.S'),
	  ('Transfer')
SELECT * FROM Payment.PaymentMethod

INSERT INTO Payment.Payments
VALUES
	  (3,30000,'2019-09-26','2019-09-18',555394,'Zee yahya','2022-04-01',2,20000)
select*from Payment.Payments

INSERT INTO ProjectDetails.WorkCodes
VALUES('Front-end'),
	  ('Back-end'),
	  ('Games'),
	  ('ATM'),
	  ('Database')
	  select * from ProjectDetails.WorkCodes

INSERT INTO ProjectDetails.ExpenseDetails
VALUES('Data'),
	  ('Food'),
	  ('Transport')
	  select * from ProjectDetails.ExpenseDetails

INSERT INTO ProjectDetails.TimeCards
VALUES
	  (2,'2021-01-14','2019-04-20',161,3,8,70000,5,3,'Game'),
	  (3,'2019-12-14','2019-01-16',250,4,8,100000,2,5,'ATM'),
	  (1,'2019-12-14','2019-01-14',300,5,8,50000,4,2,'Database')
	  select * from ProjectDetails.TimeCards

INSERT INTO ProjectDetails.TimeCardExpenses
VALUES
	  (3,'2019-05-01','2019-08-12',50000,3,3),
	  (4,'2019-09-01','2019-10-17',70000,4,2),
	  (5,'2019-08-01','2019-09-18',60000,5,1)
	  select * from ProjectDetails.TimeCardExpenses
	  







	 