select *
from [Portfilo project]..coviddeaths
order by 3, 4

select *
from [Portfilo project]..covidvaccinations
order by 2, 4

-- Death percentage

Select  continent, location, date, new_cases, cast (new_deaths as int) newdeaths, round ((total_deaths/total_cases)*100,2) totaldeathpc,
case
when new_cases = 0 then null 
else round ((new_deaths/new_cases)*100, 2) 
end as dailydeath
from [Portfilo project]..coviddeaths
where location = 'india'
order by 5 desc

-- percentage of population with covid in india

select location,date, population, total_cases, ROUND ( (total_cases/population)*100,2) infected_percentage, ROUND ( (total_deaths/population)*100,2) death_percentage
from coviddeaths
where location='india'
order by 4 desc

-- finding country with highest infection rate
select location, population, MAX ( total_cases) as totalcase, ROUND (( MAX ( total_cases)/population)*100,2) as infected_percentage
from coviddeaths
group by location ,population
having location not in ('World','High income', 'Upper middle income','Lower middle income') 
and
location not in ('Asia','Europe', 'North America', 'European Union', 'South America','Africa')
order by 3 desc

--global daily numbers 
select date, sum (new_cases) as Dailycases
from coviddeaths
group by date
having sum (new_cases) is not null
order by 1

--Total Population vs Vaccinations


-- Shows Rolling count of vaccination

with PopVax as
(
select vac.continent ,vac.location,vac.date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) over (partition by vac.location order by vac.date) as Totalvax
from covidvaccinations vac
join coviddeaths dea
on dea.location=vac.location
and dea.date=vac.date
where vac.continent is not null

)

select *
from PopVax
where Totalvax is not null
and location = 'India'
order by 2,3


-- Percentage pop vaccinated using temptable
drop table if exists #temp_vacpercentage
create table #temp_vacpercentage
( continent varchar(50),
location varchar(50),
date datetime,
population numeric,
dailyvax numeric,
totalvaccination numeric,
Singledose numeric,
Fullyvaccinated numeric

)

insert into #temp_vacpercentage
select vac.continent ,vac.location,vac.date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) over (partition by vac.location order by vac.date) as Totalvax,
vac.people_vaccinated, vac.people_fully_vaccinated
from covidvaccinations vac
join coviddeaths dea
on dea.location=vac.location
and dea.date=vac.date
where vac.continent is not null

select *, cast (Round((Singledose/population)*100,3)as float) singlepercentage , cast(Round((Fullyvaccinated/population)*100,3) as float) fullpercentage
from #temp_vacpercentage
where totalvaccination is not null
and location = 'India'