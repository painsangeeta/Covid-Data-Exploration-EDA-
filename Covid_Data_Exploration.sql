/* Covid Deaths Table */

select * from CovidDeaths where continent is not null order by 3,4;

--Select all
--From CovidDeaths
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths where continent is not null order by 1,2;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,
cast(total_deaths as float)/cast(total_cases as float)*100 as deathpercentage from CovidDeaths where continent is not null
order by 1,2;

select location, date, total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 as deathpercentage from CovidDeaths where location like '%states%' and continent is not null order by 1,2;

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

select location, date, total_cases, population, cast(total_cases as float)/cast(population as float)*100 as percentpopulationinfected from CovidDeaths where continent is not null -- where location like '%states%' 
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as highestinfectioncount, max(cast(total_cases as float)/cast(population as float))*100 as percentpopulationinfected from CovidDeaths where continent is not null group by location, population order by percentpopulationinfected desc;

-- Showing Countries with Highest Death Count per Population

select location, max(total_deaths) as totaldeathcount from CovidDeaths where continent is not null group by location order by totaldeathcount desc;

-- Let's Break Things Down By Continent

select continent, max(total_deaths) as totaldeathcount from CovidDeaths where continent is not null group by continent order by totaldeathcount desc;

-- Showing continents with the highest death count per population

select continent, max(total_deaths) as totaldeathcount from CovidDeaths where continent is not null group by continent order by totaldeathcount desc; 



--Global Numbers

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as deathpercentage from CovidDeaths where continent is not null group by date 
order by 1,2;

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as deathpercentage from CovidDeaths where continent is not null --group by date 
order by 1,2;




/* Covid Vaccinations Table */

select * from CovidVaccinations;

-- Select All
-- From CovidVaccinations Table

-- Join CovidVaccinations and CovidDeaths Table

select * from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date;

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated --(peoplevaccinated/population)*100 
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date where dea.continent is not null order by 2,3;



-- Use CTE

with popvsvac (continent, location, date, population, new_vaccinations, peoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated --(peoplevaccinated/population)*100
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null --order by 2,3
)
select *, (peoplevaccinated/population)*100 as percentpeoplevaccinated
from popvsvac;



-- Temp Table
drop table if exists #PercentPopulationVaccinated;
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (peoplevaccinated/population)*100 as percentpeoplevaccinated
from #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

select * from PercentPopulationVaccinated;







