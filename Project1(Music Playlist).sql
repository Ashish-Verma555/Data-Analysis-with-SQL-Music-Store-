USE [Project-1(music playlist)]
GO
--------------------Easy Level-------------------------

-----------------Question-1 -------------------------
--Who is senior most employee based on job title-----
Select Top 1 * From employee
Order By levels DESC
----------------------------------------------------
-----------------Question-2 -------------------------
--Which country have most invoives-----
Select billing_country as Country,count(*) as Invoice_count From invoice
Group By billing_country
Order By Invoice_count DESC
----------------------------------------------------
-----------------Question-3 -------------------------
--Top 3 valuse of total invoives-----
SELECT * From invoice

Select top 3 billing_country as Country,total From invoice
Order By total DESC
----------------------------------------------------
-----------------Question-4 -------------------------
--Which city has best customer(more money)-----
SELECT * From customer
Select billing_city,sum(total) AS total From invoice
group By billing_city
Order By Total DESC
----------------------------------------------------
-----------------Question-5 -------------------------
--Who is best customer(Spent more money)-----
Select round(Sum(i.total),2) AS [Money],c.first_name,c.last_name From invoice i
Join customer c On i.customer_id=c.customer_id
Group BY c.first_name,c.last_name
Order By [Money] DESC
----------------------------------------------------

--------------------Moderate Level-------------------------

-----------------Question-1 -------------------------
--Return email,firstName,LastName & Genre of all Rock music Listeners-----
Select DISTINCT c.first_name,c.last_name,c.email From customer c
join invoice i ON c.customer_id=i.customer_id
Join invoice_line il ON i.invoice_id=il.invoice_id
WHERE track_id IN (
SELECT track_id From genre
Where name ='ROCK')
Order By c.email 
----------------------------------------------------
-----------------Question-2 -------------------------
--Artist who written most ROCK music(Artist Name, Total track count) LIMIT 10-----
Select top 10 ar.[name],ar.artist_id,count(t.track_id) AS Count From [dbo].[artist] ar
Join album al ON ar.artist_id=al.artist_id
Join track t ON al.album_id=t.album_id
Where genre_id IN(
Select genre_id From genre
Where name='ROCK')
Group By ar.[name],ar.artist_id
Order By Count DESC

----------------------------------------------------
-----------------Question-3 -------------------------
--Track Names where(song length> AVG song length)(Name ,Milisec)-----
Select name,milliseconds From track

Where milliseconds>(
Select Avg(milliseconds) From track
)
Order By milliseconds DESC
----------------------------------------------------

--------------------Advanced Level-------------------------


-----------------Question-1 -------------------------
--Amount spent by each customer on artists(CustomerNAme, ArtistName,Total Spent)-----

WITH best_selling_artist AS
(
Select top 1 ar.artist_id AS artist_id,ar.name AS artist_name,SUM(il.unit_price*il.quantity) AS TotalSell 
From invoice_line il 
Join track t On il.track_id=t.track_id
Join album a ON t.album_id=a.album_id
Join artist ar ON a.artist_id=ar.artist_id
Group By ar.artist_id,ar.name
Order BY TotalSell DESC
)
Select c.first_name,c.last_name,bsa.artist_name,SUM(il.quantity*il.unit_price) AS totalSales From invoice i
join customer c ON c.customer_id=i.customer_id
Join invoice_line il ON i.invoice_id=il.invoice_id
Join track t ON il.track_id=t.track_id
Join album al ON t.album_id=al.album_id
Join best_selling_artist bsa ON al.artist_id=bsa.artist_id
Group By c.first_name,c.last_name,bsa.artist_name
Order by totalSales DESC

----------------------------------------------------
-----------------Question-2 -------------------------
--Popular Music Genre for each country.-----

WITH max_genre_per_country AS
(
	Select COUNT(*) AS purchase_per_genre,c.country,g.genre_id,g.name,
	ROW_NUMBER() OVER (PARTITION BY c.country
	ORDER BY COUNT(il.quantity) DESC) AS RowNo
	From invoice_line il
	Join invoice i ON i.invoice_id=il.invoice_id
	Join customer c ON c.customer_id=i.customer_id
	JOin track t ON t.track_id=il.track_id
	Join genre g ON g.genre_id=t.genre_id
	group By c.country,g.genre_id,g.name
	--Order BY c.country ASC ,purchase_per_genre DESC
)
Select * From max_genre_per_country 
where RowNo =1

----------------------------------------------------
-----------------Question-3 -------------------------
--Customer who spent more on music for each country(country,customer name,how much they spent)-----
WITH Customer_more_spent AS(
Select c.first_name,c.last_name AS CustomerName,c.country,SUM(i.total) as Totalspent,
ROW_NUMBER() OVER (PARTITION BY c.country
	ORDER BY SUM(i.total) DESC) AS RowNo
From invoice i
Join customer c ON c.customer_id=i.customer_id
Group By c.first_name,c.last_name,c.country
--Order by country
)
Select * FROM Customer_more_spent
Where RowNo like 1



-------------------------------------
--Top 10 Highest earning of artist for each country(country,customer name,how much they spent)-----
with High_earning as (
Select ar.name,i.billing_country,sum(i.total) as Earning,ROW_NUMBER() OVER (partition BY billing_country Order By sum(i.total) Desc) AS RowNo  From invoice_line il
join invoice i ON i.invoice_id=il.invoice_id
join track t ON t.track_id=il.track_id
join album a ON a.album_id=t.album_id
join artist ar ON ar.artist_id=a.album_id
Group BY ar.name,i.billing_country
)
Select Top 10 name,billing_country as Country,Earning From High_earning
Where RowNo=1