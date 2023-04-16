-- Top 10 districts with highest number of domestic visitors
select distinct district, visitors
from domestic_visitors
order by visitors desc
limit 10;

-- Top 3 districts by Compounded Annual Growth Rate
-- from 2016 to 2019
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

-- Bottom 3 districts by Compounded Annual Growth Rate
-- from 2016 to 2019
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

-- Peak and Low season months for Hyderabad
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

-- Top 3 districts with Highest Domestic to Foreign Tourists Ratio
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

-- Bottom 3 districts with Highest Domestic to Foreign Tourists Ratio
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


