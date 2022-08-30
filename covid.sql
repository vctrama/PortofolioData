/* Covid 19 Data Exploration
 
 Skill: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
 DBMS: Microsoft SQL Server Management Studio 18
 Data Source: https://ourworldindata.org/covid-deaths

*/

select *
from coviddeaths c 
where continent =''

--where location = 'Pitcairn'

update coviddeaths 
set continent = null 
where continent = ''

SELECT iso_code, continent, "location", "date", population, total_cases, new_cases, new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, hosp_patients, hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions, weekly_hosp_admissions_per_million, total_tests, new_tests, total_tests_per_thousand, new_tests_per_thousand, new_tests_smoothed, new_tests_smoothed_per_thousand, positive_rate, tests_per_case, tests_units
FROM public.coviddeaths
WHERE ;


-- Total deaths VS Total cases

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from coviddeaths c
order by 1,2 desc

-- Total cases VS Population

select location, date, population, total_cases, total_cases/population*100 as Cases_Percentage
from coviddeaths c 
order by 1,2

-- Countries with Highest infection Rate compared to Population

select location, population, max(total_cases) as highest_cases, max(total_cases/population*100) as cases_percentage
from coviddeaths c 
where total_cases is not null and population is not null
group by location, population
order by cases_percentage desc 

-- Counries with Highest Death Count per Population

select location,  max(cast(total_deaths as int)) as Total_death_count
from coviddeaths c
where continent is not null --and total_deaths is not null 
group by location
order by 2 desc nulls last

-- highest deaths by continent

select continent, max(cast(total_deaths as int)) as Total_death_count
from coviddeaths c
where continent is not null-- and total_deaths is not null 
group by continent 
order by 2 desc nulls last 


-- continent with the highest count per population

select continent, population, max(cast(total_deaths as int)) as Total_death_count
from coviddeaths c
where continent is not null-- and total_deaths is not null 
group by continent, population  
order by 2 desc nulls last 

-- GLOBAL Numbers

select --date,  
sum(new_cases) as total_case, sum(new_deaths) as total_death , sum(new_deaths)/sum(new_cases)*100 as Death_percentage --, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from coviddeaths c
where continent is not null 
--group by date
--order by 1,2 desc nulls last 
order by 1


-- Total population VS vaccinations

select cd.continent, cd."location" , cd."date" , cd.population , cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd."location", cd."date") as rolling_vaccinations
from coviddeaths cd
join covidvaccinations cv 
on cd."location" = cv."location" 
and cd."date" = cv."date" 
where cd.continent is not null
order by "location" , "date"  asc nulls last

-- 

with popvsvac (continent,"location","date",population, new_vaccinations, rolling_vaccinations)
as 
(
select cd.continent, cd."location" , cd."date" , cd.population , cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd."location", cd."date") as rolling_vaccinations
from coviddeaths cd
join covidvaccinations cv 
on cd."location" = cv."location" 
and cd."date" = cv."date" 
where cd.continent is not null
order by "location" , "date"  asc nulls last
)
select *, (rolling_vaccinations/population*100) as percentage_vaccinations
from popvsvac


-- Temp Table

drop table if exists percentage_population_vaccinated 

create table percentage_population_vaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

insert into percentage_population_vaccinated
select cd.continent, cd."location" , cd."date" , cd.population , cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd."location", cd."date") as rolling_vaccinations
from coviddeaths cd
join covidvaccinations cv 
on cd."location" = cv."location" 
and cd."date" = cv."date" 
where cd.continent is not null
order by "location" , "date"  asc nulls last

select *, (rolling_vaccinations/population*100) as percentage_vaccinations
from percentage_population_vaccinated

