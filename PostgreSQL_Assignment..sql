-- Active: 1747575507534@@127.0.0.1@5432@ph
CREATE TABLE rangers(
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    region VARCHAR(50)
);

INSERT INTO rangers(name, region) VALUES 
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range'),
('Saimon', 'Southern Hills');

SELECT * FROM rangers;


CREATE TABLE species(
    species_id SERIAL,
    common_name VARCHAR(50),
    scientific_name VARCHAR(100) UNIQUE,
    discovery_date DATE,
    conservation_status VARCHAR(25) CHECK (conservation_status IN ('Critically Endangered', 'Endangered','Vulnerable', 'Least Concern', 'Historic')),
    PRIMARY key (species_id)
);

INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES 
 ('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
 ('Bengal Tiger', 'Panthera tigris', '1758-01-01', 'Vulnerable'),
 ('Javan Rhino', 'Rhinoceros sondaicus', '1822-01-01', 'Critically Endangered'),
 ('African Lion', 'Panthera leo', '1758-01-01', 'Vulnerable'),
 ('Green Sea Turtle', 'Chelonia mydas', '1758-01-01', 'Endangered'),
 ('Blue Whale', 'Balaenoptera musculus', '1758-01-01', 'Endangered'),
 ('Giant Panda', 'Ailuropoda melanoleuca', '1869-03-11', 'Vulnerable'),
 ('American Bison', 'Bison bison', '1825-01-01', 'Least Concern'),
 ('Snowy Owl', 'Bubo scandiacus', '1758-01-01', 'Least Concern'),
 ('Mountain Gorilla', 'Gorilla beringei beringei', '1903-01-01', 'Critically Endangered');



SELECT * FROM species

CREATE Table sightings (
    sighting_id SERIAL,
    species_id INT REFERENCES species(species_id),
    ranger_id INT REFERENCES rangers(ranger_id),
    location VARCHAR(25),
    sighting_time TIMESTAMP,
    notes VARCHAR(150) DEFAULT NULL,
    PRIMARY KEY (sighting_id)
)

INSERT INTO sightings (sighting_id, species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 1, 'Peak Ridge',        '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 2, 'Bankwood Area',     '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(4, 4, 2, 'Snowfall Pass',     '2024-05-18 18:30:00', NULL),
(5, 4, 1, 'Riverbend Trail',   '2024-05-20 11:05:00', 'Heard trumpeting sounds'),
(6, 5, 3, 'South Slope',       '2024-05-22 15:00:00', 'Adult spotted near water'),
(7, 6, 2, 'High Canopy Zone',  '2024-05-25 08:15:00', 'Pair climbing trees'),
(8, 7, 1, 'Cliffside Path',    '2024-05-28 06:50:00', 'Clear paw prints found'),
(9, 2, 1, 'Western Boundary',  '2024-05-30 17:25:00', NULL),
(10, 4, 3, 'Elephant Basin',   '2024-06-01 10:40:00', 'Dust bathing behavior seen');

SELECT * FROM sightings;


-- Problem 1:Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains' 

INSERT INTO rangers(name, region) VALUES 
('Derek Fox', 'Coastal Plains');

-- Problem 2:  Count unique species ever sighted.

SELECT COUNT(DISTINCT species_id) AS unique_species_sighted
FROM sightings;

-- Problem 3: Find all sightings where the location includes "Pass".

SELECT * FROM sightings 
    WHERE location LIKE '%Pass%';


-- Problem 4: List each ranger's name and their total number of sightings.

SELECT name, count(sighting_id) as total_sightings From rangers
JOIN sightings ON sightings.ranger_id = rangers.ranger_id
GROUP BY name
ORDER BY name

-- Problem 5:  List species that have never been sighted.

SELECT common_name FROM species
LEFT JOIN sightings ON sightings.species_id = species.species_id
WHERE sightings.sighting_id IS NULL
ORDER BY common_name;

-- Problem 6: Show the most recent 2 sightings.

SELECT common_name, sighting_time, name FROM sightings
JOIN species USING(species_id) 
JOIN rangers USING(ranger_id)
ORDER BY sighting_time DESC
LIMIT 2;

-- Problem 7: Update all species discovered before year 1800 to have status 'Historic'.

SELECT * FROM species 
WHERE extract(YEAR FROM discovery_date) < 1800


ALTER TABLE species DROP CONSTRAINT species_conservation_status_check;

ALTER TABLE species 
ADD CONSTRAINT species_conservation_status_check CHECK (conservation_status IN ('Critically Endangered', 'Endangered','Vulnerable', 'Least Concern', 'Historic')) NOT VALID;

UPDATE species
SET conservation_status = 'Historic'
WHERE extract(YEAR FROM discovery_date) < 1800;

-- Problem 8: Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.

SELECT sighting_id,
CASE 
    WHEN extract( HOUR FROM sighting_time)  < 12 THEN  'Morning'
    WHEN extract( HOUR FROM sighting_time) BETWEEN 12 AND 17 THEN  'Afternoon'
    WHEN extract( HOUR FROM sighting_time)  > 17 THEN  'Evening'
    ELSE  'Night'
END as time_of_day 
FROM sightings;


-- Problem 9:  Delete rangers who have never sighted any species

SELECT * FROM rangers
WHERE NOT EXISTS (
    SELECT 1
    FROM sightings
    WHERE sightings.ranger_id = rangers.ranger_id
);

DELETE FROM rangers
WHERE NOT EXISTS (
    SELECT 1
    FROM sightings
    WHERE sightings.ranger_id = rangers.ranger_id
);
