Select * 
From PortfolioProject..CovidDeaths
Where continent is not null 
Order By 3,4

--select * 
--from PortfolioProject..CovidDeaths
--order by 3,4 

Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population 
From PortfolioProject ..CovidDeaths
Order By 1,2

--Observing total cases vs total deaths to gain insight on likelyhood of dying from contracting Covid in your country
Select Location, Date, Total_Cases, Total_Deaths,(Total_Deaths/Total_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
Order By 1,2

-- Total cases vs population in percentage 
Select Location, Date,Population, Total_Cases, (Total_Cases/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2 

--Countries with highest infection rates compared to population 
Select Location, Population, MAX(Total_Cases) as HighestInfectionCount, MAX((Total_Cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order By PercentPopulationInfected Desc

--Death count by Continent from Highest to Lowest
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is null 
Group by Location
Order By TotalDeathCount Desc

--Death count by countries from highest to low
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null 
Group By Location
Order By TotalDeathCount Desc

--Global Death Percentage due to infection per day
Select Date, SUM(New_Cases) as Total_Cases,SUM(CAST(New_Deaths as int))as Total_Deaths,SUM(CAST(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null 
Group By Date
Order By 1,2 

--Total Global Death Percentage due to infection 

Select SUM(New_Cases) as Total_Cases, SUM(CAST(New_Deaths as int)) as Total_Deaths, SUM(CAST(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null 
Order By 1,2 


-- Viewing Covid Vaccination Table 
Select * 
From PortfolioProject..CovidVaccinations

--Table Join Covid Deaths & Covid Vaccination
Select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date

--Calculating Global Vaccination total using rolling count
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
,SUM(CONVERT(int,vac.New_Vaccinations)) OVER (Partition By dea.Location Order By dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
	join PortfolioProject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date 
Where dea.Continent is not null 
Order By 2,3

--Calculating Percentage of population is vaccinated using CTE 
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
,SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition By dea.Location Order By dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.Date = vac.Date
Where dea.Continent is not null 
)Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From PopvsVac

--Calculating Percentage of population is vaccinated using Temp Table 
DROP Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
,SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition By dea.Location Order By dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date
Where dea.Continent is not null 

Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated

--Creat View to store data 
Create View PercentPopVac as
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
,SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition By dea.Location Order By dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date
Where dea.Continent is not null 

Select *
From PercentPopulationVaccinated