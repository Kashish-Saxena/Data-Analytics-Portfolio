--Selecting relevant Data

SELECT *
FROM SQLProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Calculating the death rates

SELECT location, date, total_cases, total_deaths,
(CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS death_rate
FROM SQLProject.dbo.CovidDeaths
WHERE location = 'Canada' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Calculating the infection rate

SELECT location, date, total_cases, population,
(CAST(total_cases AS float)/CAST(population AS float))*100 AS infection_rate
FROM SQLProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Country with the highest infection rate

SELECT location, population, MAX(CAST(total_cases AS int)) AS highest_infection_count,
MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 AS infection_rate
FROM SQLProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;

-- Country with the highest death count

SELECT location, population, MAX(CAST(total_deaths AS int)) AS highest_death_count,
MAX((CAST(total_deaths AS float)/CAST(population AS float)))*100 AS death_rate
FROM SQLProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_death_count DESC;

-- Continent with the highest death count

SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count,
MAX((CAST(total_deaths AS float)/CAST(population AS float)))*100 AS death_rate
FROM SQLProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_death_count DESC;

-- Continent with the highest death count

SELECT continent, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM SQLProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;

-- Global data

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths
FROM SQLProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths
FROM SQLProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

-- Total Population vs New Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS rolling_people_vaccinated
FROM SQLProject.dbo.CovidDeaths dea
JOIN SQLProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS rolling_people_vaccinated
FROM SQLProject.dbo.CovidDeaths dea
JOIN SQLProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopVsVac;

-- Using Temp Table

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
locataion nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS rolling_people_vaccinated
FROM SQLProject.dbo.CovidDeaths dea
JOIN SQLProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percentpopulationvaccinated

-- Creating view to store data for future visualization

CREATE VIEW percentpopulationvaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS rolling_people_vaccinated
FROM SQLProject.dbo.CovidDeaths dea
JOIN SQLProject.dbo.CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT * FROM percentpopulationvaccinated;