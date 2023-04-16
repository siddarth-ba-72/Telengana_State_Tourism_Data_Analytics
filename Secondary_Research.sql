-- Top 5 districts with High Population to Tourist Footfall ratio
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

-- Bottom 5 districts with High Population to Tourist Footfall ratio
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

-- Projected number of Domestic and Foreign Visitors by 2025
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

-- Project Revenue for Hyderbad in 2025 by visitors
-- Avg Spend per Tourist in Hyderabad:-
-- Foreign Tourist -> Rs.5600
-- Domestic Tourist -> Rs.1200
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
