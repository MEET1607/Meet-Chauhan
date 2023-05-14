/*Question 1:
Write a SQL Statement that will give you a count of each object type in the Adventure Works database. Order by count descending
*/

SELECT type_desc, COUNT(*) as CNT
FROM sys.objects
GROUP BY type_desc
ORDER By 2 DESC

/*
Question 2:
a. Write a SQL Statement that will show a count of schemas, tables, and columns (do not include views) in the AdventureWorks database.

b. Write a similar statement as part a but list each schema, table, and column (do not include views).
This table can be used later in the course.
*/
--a
Select COUNT(Distinct s.name) as SchemaName 
, Count(Distinct t.name) as TableName 
, Count(C.name) as ColumnName
From sys.tables t 
Inner Join sys.schemas s on t.schema_id = s.schema_id
Inner Join sys.columns c on t.object_id = c.object_id;

/*

Question 3
a. Which Purchasing vendors have the highest credit rating? (For this we have to use vendor table)

b. Using a case statement replace the 1 and 0 in Vendor.PreferredVendorStatus to "Preferred" vs "Not Preferred."   How many vendors are considered Preferred?

c. For Active Vendors only, do Preferred vendors have a High or lower average credit rating? (Cast Credit rating as a decimal)

d. How many vendors are active and Not Preferred?
*/

--a
SELECT *
FROM Purchasing.Vendor
ORDER BY CreditRating ASC; 

-- According to table defination 1 = Highest Credit rating and 5 = Lowest Credit Rating hence Order By ASC

--b
SELECT 
CASE when PreferredVendorStatus = 1 THEN 'Preferred'
ELSE 'Not Preferred'
END as PreferredStatus, Count (*) as CNT
FROM Purchasing.Vendor
Group by 
CASE when PreferredVendorStatus = 1 THEN 'Preferred'
ELSE 'Not Preferred' END;

/*c (Cast CreditRating as decimal because, the coloum has tinyint 
and it does not have decimal, so whithout casting both avgRating will be same)*/
SELECT 
CASE when PreferredVendorStatus = 1 THEN 'Preferred'
ELSE 'Not Preferred'
END as PreferredStatus, AVG(CAST (CreditRating as decimal)) as AvgRating
FROM Purchasing.Vendor
WHERE ActiveFlag = 1
Group by 
CASE when PreferredVendorStatus = 1 THEN 'Preferred'
ELSE 'Not Preferred' END;

--d
SELECT COUNT(*) as CNT
FROM Purchasing.Vendor
WHERE ActiveFlag = 1 and PreferredVendorStatus = 0;

/*
Question 4:
Assume today is August 15, 2014.

a. Calculate the age for every current employee. What is the age of the oldest employee?

b. What is the average age by Organization level? Show answer with a single decimal

c. Use the ceiling function to round up

d. Use the floor function to round down
*/

SELECT BusinessEntityID,DATEDIFF(YEAR, BirthDate, '2014-08-15') as Age
FROM HumanResources.Employee
Order by 2 DESC;
;

--b 
SELECT OrganizationLevel,
Format(Avg(cast(DATEDIFF(Year,BirthDate,'2014-08-15') as decimal)),'N1') as Age
FROM HumanResources.Employee
Group by OrganizationLevel
Order by 2 DESC;

--c
SELECT OrganizationLevel,
Format(Avg(cast(DATEDIFF(Year,BirthDate,'2014-08-15') as decimal)),'N1') as Age,
Ceiling(AVG(Cast(DATEDIFF(YEAR, BirthDate, '2014-08-15') as decimal))) as Age
FROM HumanResources.Employee
Group by OrganizationLevel
Order by 2 DESC;

--d

SELECT OrganizationLevel,
Format(Avg(cast(DATEDIFF(Year,BirthDate,'2014-08-15') as decimal)),'N1') as Age,
Ceiling(AVG(Cast(DATEDIFF(YEAR, BirthDate, '2014-08-15') as decimal))) as Age,
Floor(AVG(Cast(DATEDIFF(YEAR, BirthDate, '2014-08-15') as decimal))) as Age
FROM HumanResources.Employee
Group by OrganizationLevel
Order by 2 DESC;

/*
Question 5:
a. How many products are sold by AdventureWorks?

b. How many of these products are actively being sold by AdventureWorks?

c. How many of these active products are made in house vs. purchased?
*/

--a

SELECT COUNT (*) AS CNT
FROM Production.Product
WHERE FinishedGoodsFlag = 1;

--b. 
Select 
	Count(*) as ProductCNT
From Production.Product
Where FinishedGoodsFlag = 1
	and SellEndDate is null;
 
--c. 
Select 
	Count(*) as ProductCNT
	,Count(Case When MakeFlag = 0
				Then ProductID
				Else null End) as PurchasedProduct
	,Count(Case When MakeFlag = 1
				Then ProductID
				Else null End) as MadeInHouse
From Production.Product
Where FinishedGoodsFlag = 1
	and SellEndDate is null;

/*
Question 6:
AdventureWorks works with customers, employees and business partners all over the globe. 
The accounting department needs to be sure they are up-to-date on Country and State tax rates.

a. Pull a list of every country and state in the database.

b. Includes tax rates.

c. There are 181 rows when looking at countries and states, 
but once you add tax rates the number of rows increases to 184. Why is this?

d. Which location has the highest tax rate?
*/

--a. (Start by using the StateProvince table)
Select 
	cr.Name as 'Country'
	,sp.Name as 'State'
From Person.StateProvince sp
	Inner Join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode;
 
--b. (Use a left join when joining SalesTaxRate to StateProvince)
Select 
	cr.Name as 'Country'
	,sp.Name as 'State'
	,tr.TaxRate
From Person.StateProvince sp
	Inner Join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
	Left Join Sales.SalesTaxRate tr on tr.StateProvinceID = sp.StateProvinceID;
 
--c. ( Find the countries/states that have more than 1 tax rate)
	Select * from Sales.SalesTaxRate	
	Where StateProvinceID in (
		Select 
			sp.StateProvinceID
		From Person.StateProvince sp
		  Inner Join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
		  Left Join Sales.SalesTaxRate tr on tr.StateProvinceID = sp.StateProvinceID
		Group by sp.StateProvinceID
		Having count(*) > 1);
 
--d. 
Select 
	cr.Name as 'Country'
	,sp.Name as 'State'
	,tr.TaxRate
From Person.StateProvince sp
	Inner Join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
	Left Join Sales.SalesTaxRate tr on tr.StateProvinceID = sp.StateProvinceID
Order by 3 DESC;

/*
Question 7
Due to an increase in shipping cost you've been asked to pull a few figures related to the freight column in

Sales.SalesOrderHeader

a. How much has AdventureWorks spent on freight in totality?

b. Show how much has been spent on freight by year (ShipDate)

c. Add the average freight per SalesOrderID

d. Add a Cumulative/Running Total sum
*/

--a. 
Select 
	Format(Sum(Freight),'C0') as TotalFreight
From Sales.SalesOrderHeader;
 /*C0 to as a “precision specifier”, probably because it allows you to 
 specify the precision with which the result is displayed.*/

--b. 
Select 
	Year(ShipDate) as ShipYear
	,Format(Sum(Freight),'C0') as TotalFreight
From Sales.SalesOrderHeader
Group by Year(ShipDate)
Order by 1 ASC;
 
--c. 
Select 
	Year(ShipDate) as ShipYear
	,Format(Sum(Freight),'C0') as TotalFreight
	,Format(Avg(Freight),'C0') as AvgFreight 
From Sales.SalesOrderHeader
Group by Year(ShipDate)
Order by 1 ASC;
 
--d.
 
Select 
	ShipYear
	,Format(TotalFreight,'C0') as TotalFreight
	,Format(AvgFreight,'C0') as AvgFreight
	,Format(Sum(TotalFreight) Over (Order by ShipYear),'C0') as RunningTotal
From(
	Select 
		Year(ShipDate) as ShipYear
		,Sum(Freight) as TotalFreight
		,Avg(Freight) as AvgFreight 
	From Sales.SalesOrderHeader
	Group by 
		Year(ShipDate))a;


/*
Question 8:
Ken Sánchez, the CEO of AdventureWorks, has recently changed his email address.

a. What is Ken's current email address?

b. Update his email address to 'Ken.Sánchez@adventure-works.com'
*/

	Select *
From Person.Person p
Where p.FirstName ='Ken'
	and p.LastName = 'Sánchez'

--Here we find 2 Ken

Select 
	ea.EmailAddress --'ken0@adventure-works.com
From Person.Person p 
	Inner Join HumanResources.Employee e on e.BusinessEntityID = p.BusinessEntityID
	Inner Join Person.EmailAddress ea on ea.BusinessEntityID = p.BusinessEntityID
Where p.FirstName ='Ken'
	and p.LastName = 'Sánchez';

--b. 
Update Person.EmailAddress
Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
Where BusinessEntityID = 1;

/*
Question 9
In this question we are going to be working with Purchasing.Vendor.

a. Show each credit rating by a count of vendors

b. Use a case statement to specify each rating by a count of vendors
1 = Superior
2 = Excellent
3 = Above Average
4 = Average
5 = Below Average
c. Using the Choose Function accomplish the same results as part b (Don't use case statement).

1 = Superior
2 = Excellent
3 = Above Average
4 = Average
5 = Below Average

d. Using a case statement show the PreferredVendorStatus by a count of Vendors. 
(This might seem redundant, but This exercise will help you learn when to use
a case statement and when to use the choose function).

0 = Not Preferred
1 = Preferred

e. Using the Choose Function accomplish the same results as part d (Don't use case statement).
Why doesn't the Choose Function give the same results as part d? Which is correct?

0 = Not Preferred
1 = Preferred
*/

--a.

Select CreditRating ,Count(name) as CNT
From Purchasing.Vendor
Group by CreditRating

--b.

Select 
Case When CreditRating = 1 Then 'Superior'
	 When CreditRating = 2 Then 'Excellent'
	 When CreditRating = 3 Then 'Above Average'
	 When CreditRating = 4 Then 'Average'
	 When CreditRating = 5 Then 'Below Average'
	 Else Null End as CreditRating
,Count(name) as CNT
From Purchasing.Vendor
Group by CreditRating

--c.

Select
Choose(CreditRating, 'Superior', 'Excellent','Above Average' ,
'Average','Below Average') as CreditRating
,Count(name) as CNT
From Purchasing.Vendor
Group by CreditRating

--d.

Select
Case When PreferredVendorStatus = 0 Then 'Not Preferred'
	 When PreferredVendorStatus = 1 Then 'Preferred'
	 Else Null End as VendorStatus
	,Count(name) as CNT
	 From Purchasing.Vendor
	 Group by PreferredVendorStatus;

--e.

Select Choose(PreferredVendorStatus
,'Not Preferred','Preferred') as VendorStatus
,Count(name) as CNT
From Purchasing.Vendor
Group by PreferredVendorStatus;

/*
Question 10
a. How many Sales people are meeting their YTD Quota? Use an Inner query (subquery) to show a single value meeting this criteria

b. How many Sales People have YTD sales greater than the average Sales Person YTD sales. 
Also use an Inner Query to show a single value of those meeting this criteria.
*/

--a.
Select 
    Count(*) as CNT
From(
     Select * 
     From Sales.SalesPerson
     Where SalesYTD > SalesQuota) a;
 
--b. 
Select 
    Count(*) as CNT
From Sales.SalesPerson
Where SalesYTD >
		(Select Avg(SalesYTD)
		 From Sales.SalesPerson);

/*
Question 11:
You've been asked my Brian Welcker, VP of Sales, to create a sales report for him.

Write a script that will show the following Columns
- BusinessEntityID
- Sales Person Name - Include Middle
- SalesTerritory Name
- SalesYTD from Sales.SalesPerson

Order by SalesYTD desc
*/

Select 
    sp.BusinessEntityID
    ,Concat(FirstName,COALESCE (' ' + MiddleName, ''),' ',LastName) as FullName
    ,isnull(st.Name,'No Territory') as TerritoryName
    ,Format(sp.SalesYTD,'C0') as SalesYTD
From Sales.SalesPerson sp
    Inner Join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID
    Left Join Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
Order by sp.SalesYTD desc;

/*
Question 62:
You've been asked my Brian Welcker, VP of Sales, to create a sales report for him.
Add three columns to above question.

1. Rank each Sales Person's SalesYTD to all the sales persons. The highest
   SalesYTD will be rank number 1

2. Rank each Sales Person's SalesYTD to the sales persons in their territory.
   The highest SalesYTD in the territory will be rank number 1

3. Create a Percentile for each sales person compared to all the sales people.
The highest SalesYTD will be in the 100th percentile

*/
Select 
    sp.BusinessEntityID
    ,Concat(FirstName,COALESCE (' ' + MiddleName, ''),' ',LastName) as FullName
    ,isnull(st.Name,'No Territory') as TerritoryName
    ,Format(sp.SalesYTD,'C0') as SalesYTD
    ,RANK() Over(Order by sp.SalesYTD desc) as TotalRank
    ,RANK() Over(Partition by st.Name Order by sp.SalesYTD desc) as TerritoryRank
    ,Format(PERCENT_RANK() Over(Order by sp.SalesYTD asc),'P0') as TotalPercentRank
From Sales.SalesPerson sp
    Inner Join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID
    Left Join Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
Order by sp.SalesYTD desc;
