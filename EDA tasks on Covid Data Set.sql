--------------------------------------------------------------------------------------------------------------------------------


Select * 
from ProjectDatabase..CovidDeaths
order by location, date


Select * 
from ProjectDatabase..CovidVaccinations
order by location, date

Select location, date, total_cases, new_cases, total_deaths, population
from ProjectDatabase..CovidDeaths
order by location,date 

--------------------------------------------------------------------------------------------------------------------------------


---- 1) Calculating Death Percentage in UAE

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from ProjectDatabase..CovidDeaths
where location like '%emirates%'
order by location,date 


----  2) Percent of population got covid in uae
Select location, date, population, total_deaths, (total_cases/population) *100 as InfectedRate
from ProjectDatabase..CovidDeaths
where location like '%emirates%'
order by location, date

----------------------------------------------------------------------------------------------------------------------------------

---- 3) Looking into InfectedRate

Select location, date, population, total_deaths, (total_cases/population) *100 as InfectedRate
from ProjectDatabase..CovidDeaths
order by location, date


---- 4) Countries with Highest Infection Rate Compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as HighestInfectedRate
from ProjectDatabase..CovidDeaths
group by Location, Population
order by HighestInfectedRate desc


---- 5) Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From ProjectDatabase..CovidDeaths
--where location like '%states%'
group by location
order by TotalDeathCount desc



---- 6) Showing continets with the highest death count per population
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From ProjectDatabase..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

---- 7) Global numbers
Select date, SUM(new_cases) as  TotalCasesPerDay, SUM(CAST(new_deaths as int)) as TotatlDeathsPerDay, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100
as DeathPercentage
from ProjectDatabase..CovidDeaths
where continent is not null
group by date


---- 8) Total global numbers
Select  SUM(new_cases) as  TotalCasesPerDay, SUM(CAST(new_deaths as int)) as TotatlDeathsPerDay, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100
as DeathPercentage
from ProjectDatabase..CovidDeaths
where continent is not null
order by location, date

------------------------------------------------------------------------------------------------------------------------------------

---- 9)Looking at total Population vs Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From ProjectDatabase..CovidDeaths as dea
JOIN ProjectDatabase..CovidVaccinations as vac
    ON dea.location = vac.location
    and dea.date = vac.date
--USE CTE
With PopsVac(Continent,Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From ProjectDatabase..CovidDeaths as dea
JOIN ProjectDatabase..CovidVaccinations as vac
    ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)* 100 as RollingPercantVaccinated
From PopsVac

--TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From ProjectDatabase..CovidDeaths as dea
JOIN ProjectDatabase..CovidVaccinations as vac
    ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/population)* 100 as RollingPercantVaccinated
From #PercentPopulationVaccinated

--------------------------------------------------------------------------------------------------------------------------

----  10) Creating view to store data for later visulization

Create View NewView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From ProjectDatabase..CovidDeaths as dea
JOIN ProjectDatabase..CovidVaccinations as vac
    ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
from NewView

------------------------------------------------------------------------------------------------------------------