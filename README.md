# Telengana State Tourism Data Analytics

## This is the analysis of the tourism activity in Telangana, India from the year 2016 to 2019. A raw data was provided by the [Govt of Telangana](https://data.telangana.gov.in/search/?theme=Tourism%20and%20Culture).

## This project is the submission to the ongoing [Codebasics](https://codebasics.io/) Resume Project Challenge:- [Providing Insights to Telangana Government Tourism Department](https://codebasics.io/challenge/codebasics-resume-project-challenge)

## Tools used:-
- Python: Data cleaning
- SQL: Data Analysis
- MS Excel: Data Visualization

## Preliminary Research

### 1. Top 10 districts with highest number of domestic visitors
```
select distinct district, visitors
from domestic_visitors
order by visitors desc
limit 10;
```
![viz](https://user-images.githubusercontent.com/84430963/232984472-b49e2948-cafb-41e3-ba76-21b84d7cfdf9.png)

### 2. Top 3  and Bottom 3 Districts by CAGR(Compounded Annual Growth Rate)
#### Top 3
```
select district, avg(cagr) as CAGR
from
(
	select district, year, visitors,
    visitors/prev_visitors - 1 as cagr
	from
	   (
			select *, lag(visitors, 1) over 
		    (partition by district order by year) as prev_visitors
			from domestic_visitors
	)a
)b
group by district
order by CAGR desc
limit 3;
```
#### Bottom 3
```
select district, avg(cagr) as CAGR
from
(
	select district, year, visitors,
    visitors/prev_visitors - 1 as cagr
	from
	   (
			select *, lag(visitors, 1) over 
		    (partition by district order by year) as prev_visitors
			from domestic_visitors
	)a
)b
group by district
order by CAGR
limit 3;
```
![viz](https://user-images.githubusercontent.com/84430963/232987274-c6637b18-f72d-49ae-aa64-e1d07acc90f6.png)


### 3. Peak and Low season months for Hyderabad
```
with x as (
	select month, sum(visitors) as hyd_visitors
	from domestic_visitors
	where district="Hyderabad"
	group by month
)
select month, hyd_visitors
from x
where hyd_visitors = (
	select max(hyd_visitors)
    from x
)
union
select month, hyd_visitors
from x
where hyd_visitors = (
	select min(hyd_visitors)
    from x
);
```
![viz](https://user-images.githubusercontent.com/84430963/232988716-15bc4ad6-828a-452a-9d8e-4cf947a14780.png)


### 4. Top 3 and Bottom 3 districts with Highest Domestic to Foreign Tourists Ratio
#### Top 3
```
with ratio_table as (
	select d.district, d.visitors as dom_visitors, f.visitors as for_visitors
	from domestic_visitors d
	join foreign_visitors f
	on d.date = f.date and d.month = f.month and d.year = f.year
	group by d.district
)
select 
	district, 
    dom_visitors / nullif(for_visitors, 0) as dom_to_for_ratio
from ratio_table
order by dom_to_for_ratio desc
limit 3;
```

#### Bottom 3
```
with ratio_table as (
	select d.district, d.visitors as dom_visitors, f.visitors as for_visitors
	from domestic_visitors d
	join foreign_visitors f
	on d.date = f.date and d.month = f.month and d.year = f.year
	group by d.district
)
select 
	district,
    dom_visitors / nullif(for_visitors, 0) as dom_to_for_ratio
from ratio_table
order by dom_to_for_ratio
limit 3;
```
![viz](https://user-images.githubusercontent.com/84430963/232989946-28ed8826-29c4-4e58-a0bb-4532d3af6aca.png)

## Secondary Research

### 1. Top 5 and Bottom 5 districts with High Population to Tourist Footfall ratio
#### Top 5
```
with total_visitors_table as (
	select d.district, (d.visitors + f.visitors) as total_visitors
	from domestic_visitors d
	join foreign_visitors f
	on d.date = f.date and d.month = f.month and d.year = f.year
	group by d.district
)
select
	a.district,
	(a.total_visitors / b.population_2019) as pop_to_tour_footfall_ratio
from total_visitors_table a, population b
where a.district = b.district
group by district
order by pop_to_tour_footfall_ratio desc
limit 5;
```

#### Bottom 5
```
with total_visitors_table as (
	select d.district, (d.visitors + f.visitors) as total_visitors
	from domestic_visitors d
	join foreign_visitors f
	on d.date = f.date and d.month = f.month and d.year = f.year
	group by d.district
)
select
	a.district,
	(a.total_visitors / b.population_2019) as pop_to_tour_footfall_ratio
from total_visitors_table a, population b
where a.district = b.district
group by district
order by pop_to_tour_footfall_ratio
limit 5;
```
![viz](https://user-images.githubusercontent.com/84430963/232994046-09a0fa3d-44db-4ce2-b3f3-5d5df62ac41d.png)

### 2. Projected number of Domestic and Foreign Visitors by 2025
```
with hyd_table as (
	select
		d.district,
		d.year,
		(sum(d.visitors) + sum(f.visitors)) as total_hyd_visitors
	from domestic_visitors d
	join foreign_visitors f
	on d.year = f.year and d.month = f.month and d.date = f.date
	where d.district = "Hyderabad"
	group by d.year
),
yoy_est_table as (
	select
		h1.district,
		avg(((h2.total_hyd_visitors - h1.total_hyd_visitors)/h1.total_hyd_visitors) * 100)
		as YoY_change
	from hyd_table h1
	join hyd_table h2 on h1.year = h2.year - 1
)
select
	h.district,
    round((h.total_hyd_visitors * power((1 + y.YoY_change/100), 6)), 2)
    as Est_visitors_2025
from hyd_table h, yoy_est_table as y
where h.year = 2019;
```
![viz](https://user-images.githubusercontent.com/84430963/232994559-cbedb0fd-46b4-4239-b7a8-b04b2192b391.png)

### 3. Project Revenue for Hyderbad in 2025 by visitors
#### Avg Spend per Tourist in Hyderabad:-
#### Foreign Tourist -> Rs.5600
#### Domestic Tourist -> Rs.1200
```
with
dom_hyd as (
	select
		district,
		year,
		sum(visitors) as dom_hyd_visitors
	from domestic_visitors
	where district = "Hyderabad"
    group by year
),
yoy_dom_hyd as (
	select
		h1.district,
		avg(((h2.dom_hyd_visitors - h1.dom_hyd_visitors)/h1.dom_hyd_visitors) * 100)
		as YoY_change_dom
	from dom_hyd h1
	join dom_hyd h2 on h1.year = h2.year - 1
),
for_hyd as (
	select
		district,
		year,
		sum(visitors) as for_hyd_visitors
	from foreign_visitors
	where district = "Hyderabad"
    group by year
),
yoy_for_hyd as (
	select
		h1.district,
		avg(((h2.for_hyd_visitors - h1.for_hyd_visitors)/h1.for_hyd_visitors) * 100)
		as YoY_change_for
	from for_hyd h1
	join for_hyd h2 on h1.year = h2.year - 1
)
select
	dv.district,
    round((dv.dom_hyd_visitors * power((1 + dy.YoY_change_dom/100), 6)), 2) * 1200
    as "Est_Domestic_Revenue_2025(in Rs.)",
    round((fv.for_hyd_visitors * power((1 + fy.YoY_change_for/100), 6)), 2) * 1200
    as "Est_Foreign_Revenue_2025(in Rs.)"
from
	dom_hyd as dv, yoy_dom_hyd as dy,
    for_hyd as fv, yoy_for_hyd as fy
where dv.year = 2019 and fv.year = 2019;
```
![viz](https://user-images.githubusercontent.com/84430963/232995418-a3835ea9-06f7-4a92-86ea-46427e8f3253.png)
