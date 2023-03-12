SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3, 4

-- Select data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2

-- Looking at Total cases vs Total deaths
-- Shows the likelihood of dying for those who contract covid in Saudi.
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)) / (cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%Saudi%'
ORDER BY 1, 2

--Looking at Total cases vs Population
SELECT location, date, population, total_cases, (cast(total_cases as float) / population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Saudi%'
ORDER BY 1, 2


--Looking at contries with higher infection rates vs population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float) / population))*100 as PopulationInfectionPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Saudi%'
GROUP BY location, population
ORDER BY PopulationInfectionPercentage desc


--Countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent <> ''
GROUP BY location
ORDER BY TotalDeathCount desc

--**********************************--
--Breaking down the results by continent
--**********************************--

--Continents with the highest deaths
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent = '' AND location not like '%income%' and  location not like 'World'
GROUP BY location
ORDER BY TotalDeathCount desc

--Global numbers
SET ANSI_WARNINGS OFF
SET ARITHABORT OFF
GO
SELECT SUM(new_cases) as GlobalCases, SUM(CAST(new_deaths as int)) AS GlobalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent <> ''
--GROUP BY date
ORDER BY 1, 2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent <> ''
ORDER BY 1, 2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
--	dea.date) as RollingPeopleVaccinated,
--	(RollingPeopleVaccinated/population)*100
--FROM PortfolioProject..CovidDeaths$ dea
--JOIN PortfolioProject..CovidVaccinations$ vac
--	ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent <> ''
--ORDER BY 1, 2

--USE CTE TO USE AN ALIAS FOR AGGREGATION
WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent <> ''
--ORDER BY 1, 2
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM POPvsVAC

--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent <> ''
--ORDER BY 1, 2

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent <> ''

SELECT *
FROM PercentPopulationVaccinated