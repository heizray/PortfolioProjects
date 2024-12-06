/*
Covid-19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4
---------------------------------------------------------


-- Retrieving Data Values

Select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
From PortfolioProject..CovidDeaths
ORDER BY 1,2

----------------------------------------------------------------------


-- Looking at Total Cases vs Total Deaths

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 0) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY location, date


/*Select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPerecentage
From PortfolioProject..CovidDeaths
Order by 3,4
*/

-------------------------------------------------------------------------------------------------



-- Looking at Total Cases vs Population
-- This shows what percentage of population infected with Covid

SELECT 
    location,
    date,
    population,
	 total_cases,
    ROUND((total_cases / population) * 100, 0) AS Population_Percent
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
ORDER BY location, date

----------------------------------------------------------------------------------------------

-- Looking at Countries with Highest Viral Infection Rate Compared to Population

SELECT 
    location,
    population,
     MAX(total_cases) As HighestInfectedCount,
	 ROUND(MAX((total_cases/ population)) * 100, 0)  AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group By location, population
ORDER By PercentPopulationInfected Desc

----------------------------------------------------------------------------------------------

-- Countries with Highest Death Count

SELECT 
    location,
     MAX(CAST(total_deaths AS INT)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group By location
ORDER By TotalDeathCount Desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count

SELECT
    continent,
     MAX(CAST(total_deaths AS INT)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL
Group By continent
ORDER By TotalDeathCount Desc



----------------------------------------------------------------------------------------------

-- GLOBAL NUMBERS 

Select 
	date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPerecentage
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Not Checking by Date
Select 
	--date,
	SUM(new_cases) AS total_newcases,
	SUM(CAST(new_deaths AS INT)) AS total_newdeaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPerecentage
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


----------------------------------------------------------------------------------------------------

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved Covid Vaccine
	
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,	
	vac.new_vaccinations,
	SUM( CAST( vac.new_vaccinations AS INT)) OVER ( partition by dea.location Order by dea.location, dea.date) AS PeopleVaccinated
	--(PeopleVaccinated/population) *100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 
	ORDER BY 2,3

--- Using CTE to perform Calculation on Partition By in previous query

With PopsvsVac (continent, location, date, population, new_vaccination, PeopleVaccinated) 
AS(		
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,	
	vac.new_vaccinations,
	SUM( CAST( vac.new_vaccinations AS INT)) OVER ( partition by dea.location Order by dea.location, dea.date) AS PeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 
	--ORDER BY 2,3
)

Select *, 
	ROUND((PeopleVaccinated/population) *100, 0) AS VaccinatedPercentage
From PopsvsVac

	
-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)

Insert into  #PercentPopulationVaccinated
	select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,	
	vac.new_vaccinations,
	SUM( CAST( vac.new_vaccinations AS INT)) OVER ( partition by dea.location Order by dea.location, dea.date) AS people_vaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 

	Select *, 
	ROUND((people_vaccinated/population) *100, 0) AS VaccinatedPercentage
From  #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 






	