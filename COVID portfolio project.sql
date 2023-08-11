
SELECT * 
FROM ProtfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM ProtfolioProject..CovidVaccinations$
--ORDER BY 3,4


-- SELECT DATA THAT WE ARE GOING TO BE USING:

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM ProtfolioProject..CovidDeaths$
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHES:
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathePercentage
FROM ProtfolioProject..CovidDeaths$
WHERE location like '%saudi%'
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS POPULATION:
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date,population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM ProtfolioProject..CovidDeaths$
--WHERE location like '%saudi%'
ORDER BY 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION:

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM ProtfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--SHOWING THE COUNTRIES WITH HIGHES DEATH COUNT PER POPULATION:

SELECT location, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM ProtfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION:

SELECT continent, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM ProtfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS:

SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS INT)) as total_deaths ,SUM(cast(new_deaths AS INT))/SUM(new_cases) AS DeathPercentage
FROM ProtfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine:

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location , dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query:

WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location , dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query:

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location , dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations:

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location , dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated





