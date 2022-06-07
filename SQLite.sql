-- No. of rows into our datasets
SELECT COUNT(*) FROM Dataset10;
SELECT COUNT(*) FROM Dataset20;

-- datasets for Maharashtra and Rajasthan
SELECT * from Dataset10
WHERE state in('Maharashtra','Rajasthan');

-- Population of India
SELECT sum(population) as population FROM Dataset20;

-- average growth of every state 
SELECT state, avg(growth)
FROM Dataset10
GROUP by state;

-- average sex ratio of each state 
SELECT state, round(avg(sex_ratio),0) as avg_sex_ratio
FROM Dataset10
GROUP by state
ORDER by avg_sex_ratio desc;

-- avg literacy rate greater than 90 
SELECT state, round(avg(literacy),0) as avg_lit_rate
FROM Dataset10
GROUP by state
HAVING avg_lit_rate >90
order by avg_lit_rate desc;

-- Top 3 states showing highest growth ratio
SELECT state, avg(growth)
FROM Dataset10
GROUP by state
ORDER by avg(growth) DESC limit 3;

-- Bottom 3 states showing lowest average literacy 
SELECT state, round(avg(literacy),0) as avg_lit_rate
FROM Dataset10
GROUP by state
order by avg_lit_rate asc LIMIT 3;

-- Top and bottom 3 states in sex ratio

drop TABLE if EXISTS top_states;

CREATE TABLE top_states(
  state varchar(255),
  topstates float
  );
  
 INSERT INTO top_states
 SELECT state, sex_ratio
 FROM Dataset10
 GROUP by state
 ORDER by sex_ratio DESC;
 
 SELECT * FROM top_states;

drop TABLE if EXISTS bottom_states;

CREATE TABLE bottom_states(
  state varchar(255),
  bottomstates float
  );
  
 INSERT INTO bottom_states
 SELECT state, sex_ratio
 FROM Dataset10
 GROUP by state
 ORDER by sex_ratio asc;
 
 SELECT * FROM bottom_states;
 
 -- using union operator to combine both results 
 SELECT * FROM(
 SELECT * FROM bottom_states aSC LIMIT 3)
 UNION
 SELECT * FROM(
 SELECT * FROM top_states DESC LIMIT 3);

-- states staring with letter 'a' or ending wiht 'n'
-- Can use 'group by' function or 'distinct' function to avoid repetition
SELECT DISTINCT state FROM Dataset10
WHERE lower(state) like 'a%' or lower(state) like '%n';

-- joining both tables 
-- determining the total number of  males and females at every district by making a subquery 
SELECT c.district, c.state, round(c.population/(c.sex_rt+1),0) males, round((c.population*c.sex_rt)/(c.sex_rt+1),0) females
FROM 
(
SELECT a.district, a.state, a.sex_ratio/1000 sex_rt, b.population
FROM Dataset10 a
INNER JOIN Dataset20 b
on a.district = b.district)c;

-- determing the total number of males and females in every state by making another subquery 
SELECT d.state, sum(d.males) total_males, sum(d.females) total_females
FROM
(
SELECT c.district, c.state, round(c.population/(c.sex_rt+1),0) males, round((c.population*c.sex_rt)/(c.sex_rt+1),0) females
FROM 
(
SELECT a.district, a.state, a.sex_ratio/1000 sex_rt, b.population
FROM Dataset10 a
INNER JOIN Dataset20 b
on a.district = b.district)c)d
GROUP by d.state;

-- population in pervious census as growth rate and current population is given 
SELECT d.state, sum(d.pervious_census_population), d.current_population FROM
(
SELECT c.district, c.state, round(c.population/(1+c.growth),0)as pervious_census_population, c.population as current_population 
  FROM
(
SELECT a.district, a.state, a.growth, b.population
from Dataset10 a 
INNER join Dataset20 b 
on a.district = b.district)c)d
GROUP by d.state

-- population of India in current census and pervious census 
select sum(e.pervious_census_population) pervious_census_population, sum(e.current_population) current_population
FROM
(
SELECT d.state, sum(d.pervious_census_population) pervious_census_population, d.current_population FROM
(
SELECT c.district, c.state, round(c.population/(1+c.growth),0)as pervious_census_population, c.population as current_population 
FROM
(
SELECT a.district, a.state, a.growth, b.population
from Dataset10 a 
INNER join Dataset20 b 
on a.district = b.district)c)d
GROUP by d.state)e;

