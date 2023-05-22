SELECT *
FROM PortfolioProject..CovidVaccinationsT
WHERE continent IS NOT NULL
ORDER BY 3,4


-- to show the total number of cases, the number of new cases, the total number of deaths, and the population 


SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeathsT
WHERE continent IS NOT NULL
ORDER BY 1,2


-- to show the total cases, total deaths, and the percentage of deaths based on the total cases in the united states


SELECT Location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeathsT
--WHERE continent is not null
WHERE Location LIKE '%states'
ORDER BY 1,2


-- to show the the total cases per day by location with a rolling Percentage of the population infected


SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeathsT
WHERE continent IS NOT NULL
--WHERE Location LIKE '%states'
ORDER BY 1,2


-- to show the location, the population, to highest number of total cases, and the percent of the population that got infected


SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeathsT
WHERE continent IS NOT NULL
--WHERE Location like '%states'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- to show the total deaths by country


SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeathsT
WHERE continent IS NOT NULL
--WHERE Location like '%states'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- to show to the total deaths by continent


SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeathsT
WHERE continent IS NULL
--WHERE Location like '%states'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- to show the total cases, total deaths, and the death percentage day by day


SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeathsT
WHERE continent is not null
--WHERE Location like '%states'
GROUP BY date
ORDER BY 1,2


-- to show the total cases, the total deaths, and the Death Percentage


SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeathsT
WHERE continent IS NOT NULL
--WHERE Location like '%states'
--group by date
ORDER BY 1,2


-- to show how many new vaccinations day by day


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeathsT dea
JOIN PortfolioProject..CovidVaccinationsT vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- to show how many people were vaccinated day by day
-- also to show the total # of vaccinations by location


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY (CONVERT(varchar(30),dea.location)),dea.date)
AS RollPeopleVaccinated
FROM PortfolioProject..CovidDeathsT dea
JOIN PortfolioProject..CovidVaccinationsT vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

--to show how many people were vaccinated day by day along with the total vaccinations day by day in the united states


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY (CONVERT(varchar(30),dea.location)),dea.date)
AS RollPeopleVaccinated
FROM PortfolioProject..CovidDeathsT dea
JOIN PortfolioProject..CovidVaccinationsT vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null 
WHERE dea.location = 'United States'
ORDER BY 2,3


--creating a temp table to go back reference


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY (CONVERT(varchar(30),dea.location)),dea.date)
AS RollPeopleVaccinated
FROM PortfolioProject..CovidDeathsT dea
JOIN PortfolioProject..CovidVaccinationsT vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--creating a view for later visualization

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY (CONVERT(varchar(30),dea.location)),dea.date)
AS RollPeopleVaccinated
FROM PortfolioProject..CovidDeathsT dea
JOIN PortfolioProject..CovidVaccinationsT vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated


--


-- to show how much of the population was tested
-- doesnt actually show the percent of the population tested because in almost every case there were multiple tests
-- this is just to show the amount of tests compared to the population 
-- ex. Austria has 347% because it has a population of approx 9 million and approx 31 million tests


SELECT vac.location, SUM(vac.new_tests) as AllTests, dea.population, SUM((vac.new_tests)/dea.population)*100 AS Tested_Percent_of_Population
--, MAX(vac.total_tests) AS AllTests 
FROM PortfolioProject..CovidVaccinationsT vac
JOIN PortfolioProject..CovidDeathsT dea
	ON vac.location = dea.location
	AND vac.date = dea.date
WHERE vac.continent IS NOT NULL AND vac.new_tests IS NOT NULL 
GROUP BY dea.population, vac.location
ORDER BY location, population
--WHERE location = 'United States'