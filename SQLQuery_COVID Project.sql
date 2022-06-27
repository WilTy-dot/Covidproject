-- Looking at Total cases Vs Total deaths
-- Showing likehood of dying if you contract covid in Canada

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM Covid..Deaths
WHERE location LIKE '%canada%' AND continent is not NULL
ORDER BY 1,2

--Looking at Total Cases Vs Population
--Show what percentage of population got covid

SELECT location, date, total_cases, population,(total_cases/population)*100 as PercentagePopulatioInfected
FROM Covid..Deaths
WHERE location LIKE '%canada%' AND continent is not NULL
ORDER BY 1,2

-- Looking at countries with highest infection rates compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as PercentagePopulatioInfected
FROM Covid..Deaths
WHERE continent is not NULL
GROUP BY location, Population
ORDER BY PercentagePopulatioInfected Desc

--Showing with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid..Deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount Desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing the continents with the highest DeathCount

SELECT continent, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM Covid..Deaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount Desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CONVERT(int,new_deaths)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Covid..Deaths
WHERE continent is not null
ORDER BY 1,2

--Looking at the Total population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.total_vaccinations
FROM Covid..Deaths dea
JOIN Covid..Vaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Looking at the Population fully vaccinated Vs Population Partially vaccinated Vs Population Not Vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, (vac.people_fully_vaccinated/dea.population)*100 as PercentPeopleFullyVaccinated,
((CAST(vac.people_vaccinated as int)-CAST(vac.people_fully_vaccinated as int))/dea.population)*100 as PercentPeoplePartiallyVaccinated,
(dea.population-CAST(vac.people_vaccinated as int))/dea.population*100 as PercentNotVaccinated
FROM Covid..Deaths dea
JOIN Covid..Vaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE OF CTE

WITH poptovac (continent,location,date, population, PercentPeopleFullyVaccinated,PercentPeoplePartiallyVaccinated,PercentNotVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, (vac.people_fully_vaccinated/dea.population)*100 as PercentPeopleFullyVaccinated,
((CAST(vac.people_vaccinated as int)-CAST(vac.people_fully_vaccinated as int))/dea.population)*100 as PercentPeoplePartiallyVaccinated,
(dea.population-CAST(vac.people_vaccinated as int))/dea.population*100 as PercentNotVaccinated
FROM Covid..Deaths dea
JOIN Covid..Vaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null

)
SELECT *, (PercentNotVaccinated)*population/100 as PopulationNotvaccinated 
FROM poptovac



-- CREATING ONE SAMPLE VIEW FOR LATER VISUALIZATIONS

CREATE VIEW VaccinationShare as
SELECT dea.continent, dea.location, dea.date, dea.population, (vac.people_fully_vaccinated/dea.population)*100 as PercentPeopleFullyVaccinated,
((CAST(vac.people_vaccinated as int)-CAST(vac.people_fully_vaccinated as int))/dea.population)*100 as PercentPeoplePartiallyVaccinated,
(dea.population-CAST(vac.people_vaccinated as int))/dea.population*100 as PercentNotVaccinated
FROM Covid..Deaths dea
JOIN Covid..Vaccinations vac
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *
FROM VaccinationShare
