SELECT *
FROM portfolio.dbo.CovidDeaths$
ORDER BY 3,4


--SELECT *
--FROM portfolio.dbo.CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio.dbo.CovidDeaths$
ORDER BY 1,2


--Total cases vs Total Deaths
--% of dying after contracting Covid-19 in selected country(replace with Ghana later)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM portfolio.dbo.CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2


--% population of people who got infected by Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercePopulationInfected
FROM portfolio.dbo.CovidDeaths$
--WHERE location LIKE '%states%'
ORDER BY 1,2


--Countries with Highest infection rate to their Population
SELECT location, population, MAX(total_cases) AS HighestInfectionPercCount, Max((total_cases/population)) * 100 AS HighestInfectionRate
FROM portfolio.dbo.CovidDeaths$
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY HighestInfectionRate DESC


--Countries with Highest Death count per population 
SELECT location,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM portfolio.dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BY CONTINENT
--Death count based on continent
--Continent with the highest death count.
SELECT continent,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM portfolio.dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBSL NUMBERS
--Daily New & Death cases 
SELECT date, SUM(new_cases) AS DailyCaseCount, SUM(cast(new_deaths AS int)) AS DailyDeathCount, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DailyDeathPercCount
FROM portfolio.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--VACCINATION
--total people in the world that were vaccinated
--Calculating rolling population vaccinated

/*
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulVaccinated
FROM portfolio.dbo.CovidDeaths$ dea
JOIN portfolio.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
*/


--Using CTE to calculate for the % rolling population vaccinated
with PapvsVac (continent, location, date, population, new_vaccinations, RollingPopulVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPopulVaccinated
FROM portfolio.dbo.CovidDeaths$ dea
JOIN portfolio.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPopulVaccinated/population) * 100 AS PercRollingPopulVaccinated
FROM PapvsVac