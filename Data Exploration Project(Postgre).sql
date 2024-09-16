select *
from coviddeaths
where continent is not null --when continent is null, the location is the entire continent
order by 3,4;



-- covid vaccination
--select  *
--from covidvaccinations
--order by 3,4

select locations, dates, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2;

--Total Cases vs Total Deaths: Shows the likeihood of dying if you contract covid in your country
select locations, dates, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
where locations ILIKE '%states%' --ILIKE is a case insensitive version of LIKE
and continent is not null
order by 1,2;


---	Total Cases vs Population: Shows what percentage of population got Covid

select locations, dates, population,  total_cases,(total_cases/population)*100 as percentpopn_infected
from coviddeaths
where continent is not null
--where locations ILIKE '%states%' --ILIKE is a case insensitive version of LIKE
order by 1,2;

--Countries with Highest Infection Rate compared to Population
select locations, population,  Max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percentpopn_infected
from coviddeaths
where continent is not null
group by locations, population
order by percentpopn_infected desc nulls last;


SELECT locations, population, 
       MAX(total_cases) AS highest_infection_count, 
       MAX((total_cases::float/population)*100) AS percentpopn_infected --cast as Float
FROM coviddeaths
where continent is not null
GROUP BY locations, population
ORDER BY percentpopn_infected DESC NULLS LAST;

--Countries with Highest Death Rate compared to Population
select locations, Max(total_deaths) as total_death_count
from coviddeaths
where continent is not null 
group by locations
order by total_death_count desc nulls last;

--LET'S EXPLORE BY CONTINENT
--Continent with highest death count
select continent, Max(total_deaths) as total_death_count
from coviddeaths
where continent is not null --this does aggregate all the continents for North America for example max deaths in Canada was not added
group by continent
order by total_death_count desc nulls last;


select locations, Max(total_deaths) as total_death_count
from coviddeaths
where continent is null -- returns location where continent is null i.e, continent is same as location
group by locations
order by total_death_count desc nulls last;


--GLOBAL NUMBERS
--Number of deaths by dates globally
select dates, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,  sum(new_deaths)/sum(new_cases)*100 as new_deathpercentage
from coviddeaths
where continent is not null
group by dates
order by 1,2;

--Worldwide death
select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,  sum(new_deaths)/sum(new_cases)*100 as new_deathpercentage
from coviddeaths
where continent is not null
--group by dates
order by 1,2;


--Total popn vs Vaccinations
select *
from coviddeaths dea
join covidvaccinations vac
on dea.locations = vac.locations
and dea.dates = vac.dates;

select dea.continent, dea.locations, dea.dates, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.locations order by dea.locations, dea.dates)
as rolling_popn_vaccinated
--(aggregates the sum of new vaccinations by location and ordered by date and location)
from coviddeaths dea
join covidvaccinations vac
	on dea.locations = vac.locations
	and dea.dates = vac.dates
where dea.continent is not null	
order by 2,3 ;


--USE CTE to get percentage of rolling popn vaccinated

With popvsVac(continent, locations, dates, population, new_vaccinations, rolling_popn_vaccinated)
as
(
select dea.continent, dea.locations, dea.dates, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.locations order by dea.locations, dea.dates)
as rolling_popn_vaccinated
--(aggregates the sum of new vaccinations by location and ordered by date and location)
from coviddeaths dea
join covidvaccinations vac
	on dea.locations = vac.locations
	and dea.dates = vac.dates
where dea.continent is not null	

)

select *, (rolling_popn_vaccinated/population)*100 as rolling_popn_percent
from popvsVac


--Using Temp Table


Drop Table if exists Percent_popn_vaccinated;

Create Temporary Table Percent_popn_vaccinated
(
continent varchar(40),
locations varchar(50),
dates date,
population bigint,
new_vaccinations bigint,
rolling_popn_vaccinated numeric
);

Insert into Percent_popn_vaccinated

select dea.continent, dea.locations, dea.dates, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.locations order by dea.locations, dea.dates)
as rolling_popn_vaccinated
--(aggregates the sum of new vaccinations by location and ordered by date and location)
from coviddeaths dea
join covidvaccinations vac
	on dea.locations = vac.locations
	and dea.dates = vac.dates;
where dea.continent is not null;	


select *, (rolling_popn_vaccinated/population)*100 as rolling_popn_percent
from Percent_popn_vaccinated;


--Create View to store data for later visualization
Create View Percent_Popn_Vaccinated as

select dea.continent, dea.locations, dea.dates, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.locations order by dea.locations, dea.dates)
as rolling_popn_vaccinated
--(aggregates the sum of new vaccinations by location and ordered by date and location)
from coviddeaths dea
join covidvaccinations vac
	on dea.locations = vac.locations
	and dea.dates = vac.dates
where dea.continent is not null;	