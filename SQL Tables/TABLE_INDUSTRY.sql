USE data607_database;


CREATE TABLE Industry ( 
    Industry_ID INT AUTO_INCREMENT PRIMARY KEY, 
    Industry_Name VARCHAR(255) UNIQUE NOT NULL 
); 
-- Each industry has their own unique id. 

INSERT INTO Industry (Industry_Name) 
SELECT DISTINCT industry
FROM glassdoor_clean
WHERE industry IS NOT NULL; 

-- Insert each industry into the Industry table. Distinct to reduce duplicate
-- so each id is a unique industry
