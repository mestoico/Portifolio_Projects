USE PortifolioProject;
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths
ORDER BY 1, 2;

-- Looking at the Total Case vs Total Deaths
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS covid_death_rate
FROM Covid_Deaths
ORDER BY 1,2;

-- Looking specifically the numbers of my home country
-- Shows likelihood of dying if you contract covid in Brazil
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS covid_death_rate
FROM Covid_Deaths
WHERE location = 'Brazil'
ORDER BY 2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS covid_infection_rate
FROM Covid_Deaths
ORDER BY 1, 2;

-- Looking at countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Covid_Deaths
GROUP BY location, population
ORDER BY 4 desc;

-- Showing Countries with highest death count per population;
SELECT location, MAX(CAST(total_deaths as INT)) as total_death_count
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- Looking deaths by continent

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as INT)) as total_deaths_continent
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

 -- Global Numbers
 
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as Death_Percentage
FROM Covid_Deaths  
WHERE continent IS NOT NULL  
GROUP BY date  
ORDER BY 1,2;    

-- Looking at total population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM Covid_Deaths d 
JOIN Covid_Vaccinations v 
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

-- Using accumulative sum to know how much of the country population is vaccinated at a specific date

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, v.new_vaccinations)) OVER(PARTITION by d.location ORDER BY d.location, d.date) as Rolling_People_Vaccinated
FROM Covid_Deaths d
JOIN Covid_Vaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3;
)
SELECT *, (Rolling_People_Vaccinated/Population) * 100
FROM PopvsVac;

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations numeric,
Rolling_People_Vaccinated NUMERIC
);
INSERT INTO #PercentagePopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, v.new_vaccinations)) OVER(PARTITION by d.location ORDER BY d.location, d.date) as Rolling_People_Vaccinated
FROM Covid_Deaths d
JOIN Covid_Vaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3;

SELECT *, (Rolling_People_Vaccinated/Population) * 100
FROM #PercentagePopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationLocationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM Covid_Deaths d JOIN Covid_Vaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;
-- ORDER BY 2,3

SELECT * FROM PercentPopulationLocationVaccinated;