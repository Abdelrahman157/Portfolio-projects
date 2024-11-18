select *
from PortfolioProject..CovidDeaths

-- Select data 
select location, cast(date as date), total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths

-- looking at total cases vs total deaths
-- shows percentage of people dying from getting corona in egypt
select location, cast(date as date), total_cases, total_deaths, (convert(float,total_deaths)/NULLIF(convert(float,total_cases),0))*100 AS DeathPercentage 
from PortfolioProject..CovidDeaths
where location like 'egy%'

-- looking at total cases vs population
-- shows precentage of people that got covid

select location, cast(date as date), population, total_cases ,(NULLIF(convert(float,total_cases),0)/NULLIF(convert(float,population),0))*100 AS CovidPercentage 
from PortfolioProject..CovidDeaths
--where location like '%states%'

--looking at countries with highest infection rate to population

select location, population, MAX(cast(total_cases as int)) as MaxCovidCount ,max((NULLIF(convert(float,total_cases),0)/NULLIF(convert(float,population),0)))*100 AS CovidPercentage 
from PortfolioProject..CovidDeaths
group by location, population
order by CovidPercentage DESC


--highest mortality count per country

select location, max(cast (total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where location != 'World'
group by location 
order by HighestDeathCount desc


--highest mortality count per continent

select continent, max(cast (total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where location != 'World'
group by continent
having continent != ''
order by HighestDeathCount desc


--global numbers 

select cast(date as date), sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/NULLIF(sum(cast(new_cases as int)),0)*100 AS DeathPercentage 
from PortfolioProject..CovidDeaths
--where location like 'egy%'
where continent != ''
group by date
order by date


--total population vs people vaccinated

select dea.continent, dea.location, cast(dea.date as date), dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
cast(dea.date as date)) as SnowballVaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
order by 2,3


--use cte

with PopvsVac (continent, location, Date, Population, new_vaccinations, SnowballVaccinationCount)
as
(
select dea.continent, dea.location, cast(dea.date as date), dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
cast(dea.date as date)) as SnowballVaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3
)
select *, (SnowballVaccinationCount/NULLIF(convert(float,population),0))*100
from PopvsVac
order by 2,3