SELECT * 
FROM PortfolioDB.dbo.CovidVacc
ORDER BY 3,4

--SELECT * 
--FROM PortfolioDB.dbo.CovidDeath
--ORDER BY 3,4

--Selec Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioDB..CovidDeath
ORDER BY 1,2

-- Looking at Total cases 215535 vs Total deaths 196359

--SELECT COUNT(total_cases)
--FROM PortfolioDB..CovidDeath

--SELECT COUNT(total_deaths)
--FROM PortfolioDB..CovidDeath

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathProcentage
FROM PortfolioDB..CovidDeath
WHERE location LIKE '%canada%'
ORDER BY 1,2

--Looking at Total cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS CasesProcentage
FROM PortfolioDB..CovidDeath
WHERE location LIKE '%canada%'
ORDER BY 1,2

--Looking at countries with highest Infection rate

SELECT Location, population, MAX(total_cases) AS InfectionRate, MAX(total_cases/population)*100 AS PercantageInfected
FROM PortfolioDB..CovidDeath
--WHERE Population IS NOT NULL
GROUP BY Location, Population
ORDER BY PercantageInfected DESC

--Looking at countries with highest Death rate

SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM PortfolioDB..CovidDeath
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeaths DESC

-- By Continent

SELECT Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM PortfolioDB..CovidDeath
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeaths DESC


--Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercantage
FROM PortfolioDB..CovidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercantage
FROM PortfolioDB..CovidDeath
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

-- Total population vs Vacc

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS bigint)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingVacc
FROM PortfolioDB..CovidDeath AS CD
JOIN PortfolioDB..CovidVacc AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVacc (continent, location, date, population, new_vaccinations, RollingVacc) 
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS bigint)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingVacc
FROM PortfolioDB..CovidDeath AS CD
JOIN PortfolioDB..CovidVacc AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)

SELECT *, (RollingVacc/population)*100
FROM PopvsVacc

--TEMPTABLE

DROP TABLE IF exists #ProcPopulationVacc
CREATE TABLE #ProcPopulationVacc
(
Continent nvarchar (225),
Location  nvarchar (225),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVacc numeric 
)

INSERT INTO #ProcPopulationVacc

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS bigint)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingVacc
FROM PortfolioDB..CovidDeath AS CD
JOIN PortfolioDB..CovidVacc AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

SELECT *, (RollingVacc/population)*100
FROM #ProcPopulationVacc


CREATE VIEW PopulationVacc AS

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(CAST(CV.new_vaccinations AS bigint)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingVacc
FROM PortfolioDB..CovidDeath AS CD
JOIN PortfolioDB..CovidVacc AS CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

SELECT *
FROM PopulationVacc


