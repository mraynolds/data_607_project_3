USE data607_database;


CREATE TABLE Company ( 

    Company_ID INT AUTO_INCREMENT PRIMARY KEY, 
    Company_Name VARCHAR(255) UNIQUE NOT NULL, 
    Industry_ID INT, 
    FOREIGN KEY (Industry_ID) REFERENCES Industry(Industry_ID) 

); 
-- Each company will have its own company ID. 
-- Only one company belongs to an ID. A
-- Adding in the industry referencing the industry to the company.   

INSERT INTO Company (Company_Name, Industry_ID) 
SELECT DISTINCT company_name, i.Industry_ID 
FROM glassdoor_clean d 
JOIN Industry I ON d.industry = i.Industry_Name   
WHERE d.company_name IS NOT NULL;  


