-- Data Type

select * 
from master..CovidDeaths
order by 3, 4

select location, date, new_cases, total_deaths, population
from master..CovidDeaths
order by 1, 2


--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as Deathpercentage
from master..CovidDeaths
where location like '%States%'
order by 1, 2

--looking at total cases vs population in US

select location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
from master..CovidDeaths
where location like '%States%'
order by 1, 2


--Looking at the countries with highest infected rate compare to Population

select location,  Max(total_cases) as Higest_infected_count , population, max((total_cases/population))*100 as infected_percentage_country
from master..CovidDeaths
--where location like '%States%'
group by location, population
order by infected_percentage_country desc

--Looking at highest death count per population


select location,  Max(total_cases) as Higest_infected_count, max(total_deaths) as Higest_deaths_count , population, max((total_deaths/population))*100 as death_percentage_country
from master..CovidDeaths
--where location like '%States%'
group by location, population
order by death_percentage_country desc

--Lets clear more


select location, max(cast(total_deaths as int)) as death_counts
from master..CovidDeaths
group by location
order by death_counts desc

--Lets break deaths by Continents

select continent, max(cast(total_deaths as int)) as death_counts
from master..CovidDeaths
where continent is not null
group by continent
order by death_counts desc

-- Global Number

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as death_percentage
from master..CovidDeaths
where continent is not null
group by date
order by 1, 2
 -- first case was reported on 2020/01/22

 --Looking at Total population vs Total Vacination

 select dea.continent, dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations
 from master..CovidDeaths dea
 join master..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location like '%India%'
order by  2, 3

-- In India the vacination program began at 2021-01-16 with 191181 people vaccinated.

--Looking at Total population vs Total Vacination

with POPvsVAC (continent, location, date, population, new_vaccinations, Rolling_people_vaccination)
as(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccination
 from master..CovidDeaths dea
 join master..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%India%'
)
select *, (Rolling_people_vaccination/population)*100 as Percentage_vacinated
from POPvsVAC

--Looking at Total population vs Total Vacination with table technique

Create Table #TPvsTV
(
continent nvarchar(222),
location nvarchar(222),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccination numeric)

Insert into #TPvsTV
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccination
 from master..CovidDeaths dea
 join master..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%India%'

select *, (Rolling_people_vaccination/population)*100 as Percentage_vacinated
from #TPvsTV


-- Creating view for later visualizaition

create view TPvsTV as 
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccination
 from master..CovidDeaths dea
 join master..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%India%'
