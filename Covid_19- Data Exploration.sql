/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * FROM covid_19.coviddeaths;


-- Data was selected to begin with.

SELECT location, date, total_cases, new_cases, total_deaths, population FROM covid_19.coviddeaths
WHERE continent != 'NULL' 
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_19.coviddeaths
WHERE continent != 'NULL'
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS covid_percentage
FROM covid_19.coviddeaths
WHERE continent != 'NULL' and location = 'India'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT 	location, population, MAX(total_cases) as HighestInfectionCount,  
		Max((total_cases/population))*100 as PercentPopulationInfected
FROM covid_19.coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Moldova, Bosnia, and Colombia Exhibit the Highest Infection Rates Relative to Their Population Size


-- Countries with Highest Death Count per Population

SELECT 	location, MAX(cast(total_deaths AS SIGNED)) AS totalDeathCount 
FROM covid_19.coviddeaths
GROUP BY location
ORDER BY totalDeathCount DESC;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT 	continent, MAX(cast(total_deaths AS SIGNED)) AS totalDeathCount 
FROM covid_19.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED)) AS total_Death, 
		SUM(cast(new_deaths AS SIGNED))/SUM(new_cases)*100 AS death_percentage
FROM covid_19.coviddeaths;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_19.coviddeaths dea
JOIN covid_19.covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_19.coviddeaths dea
JOIN covid_19.covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percent_of_peoplevaccinated
FROM PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_19.coviddeaths dea
JOIN covid_19.covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percent_of_peoplevaccinated
FROM PopvsVac;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_19.coviddeaths dea
JOIN covid_19.covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM covid_19.percentpopulationvaccinated;

