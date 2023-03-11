create database bike_sharing_assignment;
use bike_sharing_assignment;
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/trip.csv"
into table trip FIELDS TERMINATED BY ',' IGNORE 1 LINES;
-- In str to date minutes is specified as %i
update trip set start_date =  STR_TO_DATE(start_date,'%m/%d/%Y %H:%i');
update trip set end_date =  STR_TO_DATE(end_date,'%m/%d/%Y %H:%i');
alter table trip modify start_date datetime;
alter table trip modify end_date datetime;
select * from trip limit 10;
select * from status limit 10;
select * from station limit 10;
-- Total Bike Stations
select count(*) as total_bike_stations from station;
-- Total Number of Bikes
select count(distinct(bike_id)) as total_number_of_bikes from trip;
-- Total Number of Trips
select count(distinct(id)) as total_number_of_trips from trip;

-- First Trip
select * from trip 
order by start_date
limit 1;

-- Last Trip
select * from trip 
order by start_date desc
limit 1;

-- Average duration of all the trips
select avg(duration) from trip;	

-- Of trips on which customers are ending their rides at the same station from where they started?
select avg(duration) as average_duration from trip
where start_station_name = end_station_name;

-- Which bike has been used the most in terms of duration? (Answer with the Bike ID)
select bike_id from trip
group by bike_id
order by sum(duration) desc limit 1;


-- What are the top 10 least popular stations? 
-- Hint: Find the least frequently appearing start stations from the Trip table
select start_station_id,start_station_name,count(start_station_name) as Start_station_name_count
from trip
group by start_station_name
order by count(start_station_name)
limit 10
;

-- Idle time is the duration for which a station remains inactive. 
-- You can consider this as the time for which a station has more than 3 bikes available.
-- Find the idle time for Station 2 on the date '2013/08/29'
select sum(timestampdiff(second,st.time,st.lead_bikes_available_time)) as idle_time
from(
select *,
LEAD(time) OVER(order by time) as lead_bikes_available_time
from status
where station_id = '2'
and date(time) = "2013-08-29"
) as st
where bikes_available > 3
;
select * from unpopular_idle_time_stations;

-- You can find the SQL code for this formula given below. 
-- Use the findings above to recommend three stations that can be shut. 
-- (open ended) For example, if the Japantown and Ryland stations are nearby, 
-- and the Japantown is not as popular as the Ryland station, then it can be recommended to shut.
select *,
acos(
cos(radians( st.lat ))
* cos(radians( st.lead_lat ))
* cos(radians( st.long ) - radians( st.lead_long ))
+ sin(radians( st.lat ))
* sin(radians( st.lead_lat ))
) AS consecutiveStationDistance from (select *, 
LEAD(station.lat) OVER(ORDER BY station.id) as lead_lat,
LEAD(station.long) OVER(ORDER BY station.id ) as lead_long
from station
) AS st
;
-- Least Popular Stations
select * from unpopular_stations;
create view unpopular_stations as
select start_station_id,start_station_name,
rank() over(order by count(start_station_name)) as Unpopular_station_rank
from trip
group by start_station_name;

select * from unpopular_stations;
-- Calculating idle time for all stations
create view  idle_time_stations as
select station_id,sum(timestampdiff(second,st.time,st.lead_bikes_available_time)) as idle_time
from(
select *,
LEAD(time) OVER(partition by station_id order by time) as lead_bikes_available_time
from status
) as st
where bikes_available > 3
order by idle_time desc; 
-- Join idle time and least used stations
drop view unpopular_idle_time_stations;
create view unpopular_idle_time_stations as
select start_station_id as station_id, start_station_name,Unpopular_station_rank,idle_time
from unpopular_stations
left join idle_time_stations
on station_id = start_station_id;
select * from unpopular_idle_time_stations;
-- New Query
drop view least_distance_consecutive_stations;
create view least_distance_consecutive_stations as
select id,name,lat,st.long,lead_lat,lead_long,unpopular_station_rank,idle_time,
acos(
cos(radians( st.lat ))
* cos(radians( st.lead_lat ))
* cos(radians( st.long ) - radians( st.lead_long ))
+ sin(radians( st.lat ))
* sin(radians( st.lead_lat ))
) AS consecutiveStationDistance from (select *, 
LEAD(unp_st.lat) OVER() as lead_lat,
LEAD(unp_st.long) OVER( ) as lead_long
from 
(select * from station
inner join unpopular_idle_time_stations
on station.name = unpopular_idle_time_stations.start_station_name
) as unp_st
) AS st;
select count(*) from least_distance_consecutive_stations;


select * from station
inner join unpopular_idle_time_stations
on station.name = unpopular_idle_time_stations.start_station_name
;

select * from least_distance_consecutive_stations;
-- For calculating which station to shut down
select * from unpopular_idle_time_stations
where station_id in (10,11);




-- Calculate the average number of bikes and docks available for Station 2.(Hint: Use the Status table.)
select station_id, avg(bikes_available) as average_number_of_bikes, avg(docks_available) as average_number_of_docks 
from status
where station_id = 2;


select start_station_id,start_station_name,count(start_station_name),
rank() over(order by count(start_station_name)) as Unpopular_station_rank
from trip
group by start_station_id;

select start_station_id,start_station_name,count(start_station_name)
from trip
group by start_station_name
order by count(start_station_name)
;

select start_station_id,start_station_name,count(start_station_name)
from trip
group by start_station_name
order by count(start_station_name)
;

select start_station_id,start_station_name,count(start_station_name)
from trip
group by start_station_name
order by count(start_station_name)
;

 


