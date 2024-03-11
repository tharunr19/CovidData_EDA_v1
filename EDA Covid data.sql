-- Select data to be used in project

SELECT country, date_id, total_cases, new_cases, total_deaths, population
FROM covid_data.covid_deaths
ORDER BY country, date_id;


-- Show different countries included in the data

SELECT DISTINCT iso_code, country
FROM covid_data.covid_deaths;

-- Looking at total cases vs total deaths. Shows the likelihood of dying if you contract Covid in the UK.

SELECT country, date_id, total_cases, total_deaths, (total_deaths / total_cases) * 100 as death_percentage
FROM covid_data.covid_deaths
WHERE country = "United Kingdom" 
ORDER BY country, date_id;

-- Look at the highest UK death percentage

SELECT country, MAX(total_deaths / total_cases) * 100 as death_percentage
FROM covid_data.covid_deaths
WHERE country = "United Kingdom"
GROUP BY country;

-- Look at total cases vs population. Shows the percentage of populaton who contracted Covid within the UK.

SELECT country, date_id, total_cases, population, (total_cases/population) * 100 as infection_rate
FROM covid_data.covid_deaths
WHERE country = "United Kingdom" 
ORDER BY country, date_id;

-- Which countries have the highest infection rates.

SELECT country, population, MAX(total_cases) as max_infection_count, MAX((total_cases / population)) * 100 as max_infection_rate
FROM covid_data.covid_deaths
GROUP BY country, population
ORDER BY max_infection_rate desc;

-- Which countries had the highest death rates count.

SELECT country, population, sum(new_deaths) as total_death_count
FROM covid_data.covid_deaths
WHERE continent IS NOT NULL
GROUP BY country, population
ORDER BY total_death_count desc;

-- Showing continents with the highest death count per population

SELECT continent, sum(new_deaths) as total_death_count
FROM covid_data.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count desc;

-- Global analysis of total cases, deaths and percentage of deaths per case (on a daily basis).

SELECT date_id, SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases) * 100 as death_percentage
FROM covid_data.covid_deaths
WHERE continent IS NOT NULL 
GROUP BY date_id
ORDER BY date_id;

-- Total global cases, deaths and percentage of deaths per case.

SELECT SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases) * 100 as death_percentage
FROM covid_data.covid_deaths
WHERE continent IS NOT NULL;

-- Looking at Covid vaccinations table

SELECT 
dea.continent,
dea.country,
dea.date_id,
dea.population,
vac.new_vaccinations,
	SUM(vac.new_vaccinations) 
    OVER (partition by dea.country
    ORDER BY dea.country, dea.date_id) as rolling_count_vaccinations
    FROM covid_data.covid_deaths dea
JOIN covid_data.covid_vaccinations vac
	ON dea.country = vac.country
    AND dea.date_id = vac.date_id
WHERE dea.continent IS NOT NULL
ORDER BY dea.country, dea.date_id;

-- Using CTE to create a table which shows the rolling percentage of people vaccinated in relation to population, through time.

WITH PopvsVac
(
continent, 
country,
date_id,
population,
new_vaccinations,
rolling_count_vaccinations
)
AS 
(
SELECT 
dea.continent,
dea.country,
dea.date_id,
dea.population,
vac.new_vaccinations,
	SUM(vac.new_vaccinations) 
    OVER (partition by dea.country
    ORDER BY dea.country, dea.date_id) as rolling_count_vaccinations
    FROM covid_data.covid_deaths dea
JOIN covid_data.covid_vaccinations vac
	ON dea.country = vac.country
    AND dea.date_id = vac.date_id
WHERE dea.continent IS NOT NULL)
select 
*,
((rolling_count_vaccinations / population)*100) as percentage_people_vaccinated
FROM PopvsVac;


