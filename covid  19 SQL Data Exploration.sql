SELECT *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
 order by 1,2


-- Looking at Total Cases vs Total Deaths
-- show likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
 order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid  

SELECT location,date,population,total_cases,(total_deaths/population)*100 as   PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
 order by 1,2

--Looking at countries with Highest Inflection Rate compared to population

SELECT location,population,max(total_cases)as HigestInfectionCount, max((total_cases/population))*100 as  PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
group by location,population
order by PercentPopulationInfected desc


-- Showing Countries Highest Death Conts per Population 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
 Where continent is not null 
Group by Location
order by TotalDeathCount desc 


--Lets's Break Thing By Continent


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc	


--showing Contents with the highest Death Count 


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
 Where continent is not null 
Group by continent
order by TotalDeathCount desc 



-- GLOBAL NUMBERS

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null 
--Group By date
order by 1,2

-- looking at Total population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

with popvsVac(continential,location,date,population,New_vaccinations,RollingPeopleVaccined)	
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *,(RollingPeopleVaccined/ population)*100
from popvsVac

-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Creating View to Store date for later visualizations
 
 create view PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


select *
from PercentPopulationVaccinated
