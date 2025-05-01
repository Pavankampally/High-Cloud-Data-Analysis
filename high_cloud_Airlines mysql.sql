create database high_cloud_airlines;
 use high_cloud_airlines;
 select * from maindata;
 
 
 
 
 ## Q1- Getting Date Field
 ALTER TABLE Maindata ADD COLUMN Date_Field DATE;
 ALTER TABLE Maindata RENAME COLUMN `Month (#)` to Month;
 ALTER TABLE Maindata RENAME COLUMN `# Available Seats` to Available_Seats;
 ALTER TABLE Maindata RENAME COLUMN `# Transported Passengers` to Transported_Passengers;
 ALTER TABLE Maindata RENAME COLUMN `Carrier Name` to Carrier_Name;
 ALTER TABLE Maindata RENAME COLUMN `# Departures Scheduled` to Departures_Scheduled;
 ALTER TABLE Maindata RENAME COLUMN `# Departures Performed` to Departures_Performed;
 ALTER TABLE Maindata RENAME COLUMN `From - To City` to From_To_City;
 ALTER TABLE Maindata RENAME COLUMN `%Distance Group ID` to Distance_group_ID;
 ALTER TABLE distance_groups RENAME COLUMN `ï»¿%Distance Group ID` to Distance_group_ID;
 ALTER TABLE distance_groups RENAME COLUMN `Distance Interval` to Distance_interval;
 ALTER TABLE Maindata RENAME COLUMN `%Airline ID` to Airline_ID;
 
 UPDATE Maindata SET Date_Field = 
 STR_TO_DATE(CONCAT(Year, '-', LPAD(Month, 2, '0'), '-', LPAD(Day, 2, '0')), '%Y-%m-%d');
 
 ## KPI-1
 ## Q1.A. Year
 SELECT Year(Date_Field) FROM Maindata;
 
 ## Q1.B. Month No
  SELECT Month(Date_Field) as Month_No FROM Maindata;
  
  ## Q1.C Month Name
  SELECT Month, MONTHNAME(Date_Field) as Month_Name FROM Maindata;
  
  ## Q1.D Quarter
  SELECT MONTHNAME(Date_Field) as Month_Name, QUARTER(Date_Field) as Quarter FROM Maindata;
  
  ## Q1.E Year_Month (YYYY-MMM)
  SELECT DATE_FORMAT(Date_Field, '%Y-%b') AS YearMonth FROM Maindata;
  
  ## Q1.F. WeekDaysNo. 
  SELECT DAYOFWEEK(Date_Field) as Weekday_No FROM Maindata;
         
 ## Q1.G. Weekday Name
 SELECT DAYNAME(Date_Field) as Weekday_name FROM Maindata;
         
 ## Q1.H. Financial Month
 SELECT MONTHNAME(Date_Field),
 CASE
     WHEN MONTH(Date_Field) >= 4 THEN MONTH(Date_Field) - 3
     ELSE MONTH(Date_Field) + 9
   END AS FinancialMonth
 FROM Maindata;
 
 ## Q1.I Financial Quarter
 SELECT MONTH(Date_Field),
   CASE
     WHEN MONTH(Date_Field) BETWEEN 4 AND 6 THEN 'Q1'
     WHEN MONTH(Date_Field) BETWEEN 7 AND 9 THEN 'Q2'
     WHEN MONTH(Date_Field) BETWEEN 10 AND 12 THEN 'Q3'
     ELSE 'Q4'
   END AS FinancialQuarter
 FROM Maindata;
 
 SELECT Year, Month, Day, MONTHNAME(Date_Field), QUARTER(Date_Field), DATE_FORMAT(Date_Field, '%Y-%b') AS YearMonth,
 		DAYOFWEEK(Date_Field), DAYNAME(Date_Field),
 CASE
     WHEN MONTH(Date_Field) >= 4 THEN MONTH(Date_Field) - 3
     ELSE MONTH(Date_Field) + 9
   END AS FinancialMonth,
   CASE
     WHEN MONTH(Date_Field) BETWEEN 4 AND 6 THEN 'Q1'
     WHEN MONTH(Date_Field) BETWEEN 7 AND 9 THEN 'Q2'
     WHEN MONTH(Date_Field) BETWEEN 10 AND 12 THEN 'Q3'
     ELSE 'Q4'
   END AS FinancialQuarter
 FROM Maindata;
 
 
 ## KPI-2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)
 
 SELECT YEAR(Date_Field) AS Year, QUARTER(Date_Field) AS Quarter, MONTH(Date_Field) AS Month,
   SUM(Transported_Passengers) AS Total_Transported_pass,
   SUM(Available_Seats) AS Total_Available_seats,
 (SUM(Transported_Passengers) / SUM(Available_Seats)) * 100 AS Load_Factor_Percentage
 FROM Maindata GROUP BY Year, Quarter, Month ORDER BY Year, Quarter, Month;
 
 ## KPI-3. The load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
 
 SELECT Carrier_Name,
   SUM(Transported_Passengers) AS Total_Transported_passengers,
   SUM(Available_Seats) AS Total_Available_seats,
   ifnull((SUM(Transported_Passengers) / nullif(SUM(Available_Seats),0)) * 100,0) AS Load_Factor_Percentage
 FROM Maindata GROUP BY Carrier_Name;
 
 ## KPI-4. Identify Top 10 Carrier Names based passengers preference 
 
 SELECT Carrier_Name,
   count(transported_passengers) as Total_passengers
   from maindata
   group by carrier_name
   order by Total_passengers desc;
   
   
 ## KPI-5.  Display top Routes ( from-to City) based on Number of Flights.
 
 SELECT From_To_City AS Route,
 	count(*)
as Number_of_Flights 
from maindata
group by Route
order by Number_of_flights desc limit 10;

 ## KPI-6. Identify the how much load factor is occupied on Weekend vs Weekdays.
 
 SELECT
     CASE WHEN DAYOFWEEK(Date_Field) IN (1, 7) THEN 'Weekend'
         ELSE 'Weekday'
     END AS Day_Type,
     SUM(Transported_Passengers) AS Total_Transported_pass,
   SUM(Available_Seats) AS Total_Available_seats,
   (SUM(Transported_Passengers) / SUM(Available_Seats)) * 100 AS Load_Factor_percentage
 FROM Maindata GROUP BY Day_Type;
 
 ## KPI-7. Identify number of flights based on Distance groups
 
 SELECT 
 Distance_interval, count(Airline_ID) as Total_Flights
 from maindata 
 join distancegroups on maindata.Distance_group_ID = distancegroups.Distance_group_ID
 group by Distance_interval
 order by Total_Flights desc;