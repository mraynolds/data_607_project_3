USE data607_database;


CREATE TABLE Location ( 
    Location_ID INT AUTO_INCREMENT PRIMARY KEY, 
    City VARCHAR(255), 
    State VARCHAR(255), 
    Country VARCHAR(255) 
); 
-- Each location has their own unique id. 


INSERT INTO Location (City, State, Country) 
SELECT DISTINCT city, state, country  
FROM glassdoor_clean
WHERE city IS NOT NULL ; 
-- Insert each city, state, and country into location table.  
