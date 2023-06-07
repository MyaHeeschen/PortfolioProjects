/*

	COVID Exploration

	Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select * 
from CovidDeaths
where continent is not NULL
order by 3,4

--select * 
--from CovidVaccinations
--order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2



--total_cases orginally nvarchar
alter table CovidDeaths
alter column total_cases float

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID based on country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2


--Total Cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from CovidDeaths
where location like '%states%'
order by 1,2


--Countries with greatest infection rates
select location, population, max(total_cases) as HighestCOVIDCount, max((total_cases/population))*100 as CovidPercentage
from CovidDeaths
group by location, population
order by 4 desc


--Countries with highest death counts
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by location
order by 2 desc


--Death count by continent
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is NULL
group by location
order by 2 desc
--Divided world by income bracketts


--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2



--Population vs Vaccination Status
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE
with PopvVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvVac


--Temp table

drop table if exists #PercentPopVacc
create table #PercentPopVacc
(
continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)

insert into #PercentPopVacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopVacc


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

create view GlobalNumber as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 

create view ContinentDeathCount as
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is NULL
group by location

create view CountryDeathCount as
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by location