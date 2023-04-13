//
select *
from [dbo].[CovidDeaths]
where location like '%income%'
order by 1,2

select *
from [dbo].[CovidVaccinations]

Select Location , date , total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From [dbo].[CovidDeaths]
where Location like '%viet%'
order by 1,2 

--looking at Total Cases vs Population 
--Shows what percentage  of population got Covid 
Select Location , date ,population, total_cases , (total_cases/population)*100 as InfectionPercentage  
From [dbo].[CovidDeaths]
where Location like '%viet%'
order by InfectionPercentage desc

--Looking at Countries with highest Infection rate compared to Population 
Select location , max(total_cases)as Highest_cases , population , max((total_cases/population)*100) as HighestInfectionPercentage 
from [dbo].[CovidDeaths]
group by location , population 
order by  HighestInfectionPercentage desc

--Showing the Country with Highest Death Count Perpopulation 
Select location , Max (total_deaths)as TotalDeathCount 
from [dbo].[CovidDeaths]
where continent is not null
group by location 
order by  TotalDeathCount desc

--Showing the continent with Highest Death Count Perpopulation 
Select location , Max (total_deaths)as TotalDeathCount 
from [dbo].[CovidDeaths]
where continent is null and location not like '%income%'
group by location 
order by  TotalDeathCount desc

----Showing the DeathCount base on income ? 
Select location , Max (total_deaths)as TotalDeathCount 
from [dbo].[CovidDeaths]
where location like '%income%'
group by location 
order by  TotalDeathCount desc

--Global Numbers 
Select   Sum(new_cases) as total_cases , sum(new_deaths) as total_death ,
COALESCE ((Sum(new_deaths)/NULLIF (Sum(new_cases),0))*100, 0) as DeathPercentage 
From [dbo].[CovidDeaths]
--where Location like '%viet%'
where continent is not null 
--group by date	
order by 1,2

--looking at the total population vs Vaccination in the world 
select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) over (partition by dea.Location order by 
dea.location , dea.date ) as RollingpeopleVaccinated ,
--(RollingpeopleVaccinated/dea.population)*100 as VaccinatedPercentage 
from [dbo].[CovidVaccinations] vac 
join  [dbo].[CovidDeaths] dea 
	on vac.date = dea.date
	and vac.location = dea.location  
where dea.continent is not null 
order by 2,3 

--USE CTE table here to see the Vaccinated percentage 
With PopvsVac (continent,location, date , population, new_vaccinations,RollingpeopleVaccinated)
as
(select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) over (partition by dea.Location order by 
dea.location , dea.date ) as RollingpeopleVaccinated 
from [dbo].[CovidVaccinations] vac 
join  [dbo].[CovidDeaths] dea 
	on vac.date = dea.date
	and vac.location = dea.location  
where dea.continent is not null 
 )
Select * ,(RollingpeopleVaccinated/population)*100 as VaccinatedPercentage 
	From PopvsVac

--option 2 , using temptable 
DROP TABLE IF Exists #temp_PopvsVac
Create table #temp_PopvsVac ( 
continent nvarchar(255),
location nvarchar(255) ,
date  datetime ,
population  float,
New_Vaccinations bigint ,
RollingpeopleVaccinated bigint 
) 

INSERT INTO #temp_PopvsVac 
select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.Location order by 
dea.location , dea.date ) as RollingpeopleVaccinated 
From [dbo].[CovidVaccinations] vac 
join  [dbo].[CovidDeaths] dea 
	on vac.date = dea.date
	and vac.location = dea.location  
where dea.continent is not null ;
select * , (RollingpeopleVaccinated/population)*100 as VaccinatedPercentage
from #temp_PopvsVac 


















