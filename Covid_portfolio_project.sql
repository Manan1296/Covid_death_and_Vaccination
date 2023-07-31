SELECT *
FROM Portfolio_Project..covid_data_death
ORDER BY 3,4

--SELECT *
--FROM Portfolio_Project..covid_data_vaccination
--ORDER BY 3,4

SELECT
 location, date, total_cases, new_cases, total_deaths, population
FROM
 Portfolio_Project..covid_data_death
 order by 1,2

 -- finding total case vs total death

 SELECT
 location, date, total_cases, new_cases, total_deaths
 ,(cast(total_deaths as float)/CAST(total_cases AS float))*100 AS Death_Percentage
FROM
 Portfolio_Project..covid_data_death
 WHERE
 location LIKE '%IND%'
 order by 1,2

 --finding total_cases vs population

 SELECT
 location, date, population, total_cases
 ,(cast(total_cases as float)/CAST(population AS float))*100 AS total_case
FROM
 Portfolio_Project..covid_data_death
 WHERE
 location LIKE '%IND%'
 order by 1,2

 --find country with highest case#
 SELECT
  TOP 10 
  location, population, 
  max(total_cases) as highest_infection
 ,Max((cast(total_cases as float)/CAST(population AS float)))*100 AS INFECTED_POPULATION
FROM
 Portfolio_Project..covid_data_death
 --WHERE location LIKE '%IND%'
 GROUP BY population, location
 order by INFECTED_POPULATION DESC

 --FINDING COUNTRY WITH HIGHEST DEATH

SELECT
  location, 
  max(cast(total_deaths as int)) AS Hightest_deaths
FROM
 Portfolio_Project..covid_data_death
Where
 continent is not null
GROUP BY location
order by Hightest_deaths DESC

-- finding globle number
SELECT
--date,
SUM(new_cases) AS total_new_cases,
SUM(CAST(new_deaths AS int)) AS total_new_daths
,SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS  death_Percentage
FROM
 Portfolio_Project..covid_data_death
WHERE
  new_cases <> '0' AND new_deaths <> '0'
--GROUP BY date
ORDER BY 1,2

--looking for total populatin vs vaccination

SELECT
dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER ( partition by dea.Location ORDER by dea.Location, DEA.date) AS rollling_peopl_vaccinated,
(rollling_peopl_vaccinated/population)*100
FROM
Portfolio_Project..covid_data_death dea
JOIN Portfolio_Project..covid_data_vaccination vac
 on dea.location=vac.location 
 and dea.date=vac.date
where
 dea.continent is not null
order by 2,3

-- use of CTE
with popvsvac (continent, location,date, population, new_vaccinations, rollling_peopl_vaccinated)
AS
(SELECT
dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert (INT, vac.new_vaccinations)) OVER ( partition by dea.Location ORDER by dea.Location, DEA.date) AS rollling_peopl_vaccinated
--(rollling_peopl_vaccinated/population)*100
FROM
Portfolio_Project..covid_data_death dea
JOIN Portfolio_Project..covid_data_vaccination vac
 on dea.location=vac.location 
 and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (rollling_peopl_vaccinated/population)*100
From popvsvac

--USE OF TEMP TABLE
drop table if exists #percentagepopulationvaccinated
CREATe TABLE #percentagepopulationvaccinated
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #percentagepopulationvaccinated
SELECT
dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert (float, vac.new_vaccinations)) OVER ( partition by dea.Location ORDER by dea.Location, DEA.date) AS rollling_peopl_vaccinated
--(rollling_peopl_vaccinated/population)*100
FROM
Portfolio_Project..covid_data_death dea
JOIN Portfolio_Project..covid_data_vaccination vac
 on dea.location=vac.location 
 and dea.date=vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (Rolling_people_vaccinated/population)*100
From #percentagepopulationvaccinated

-- creating view for viz

CREATE VIEW percentagepopulationvaccinated AS
SELECT
dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert (float, vac.new_vaccinations)) OVER ( partition by dea.Location ORDER by dea.Location, DEA.date) AS rollling_peopl_vaccinated
--(rollling_peopl_vaccinated/population)*100
FROM
Portfolio_Project..covid_data_death dea
JOIN Portfolio_Project..covid_data_vaccination vac
 on dea.location=vac.location 
 and dea.date=vac.date
where dea.continent is not null 
--order by 2,3


SELECT *
FROM percentagepopulationvaccinated