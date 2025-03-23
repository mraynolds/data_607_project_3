USE data607_database;


CREATE TABLE Job_Postings (
    Job_ID INT AUTO_INCREMENT PRIMARY KEY,
    Title Text,
    Job_Description Text,
    Avg_Salary Text,
    r_lang Int,
    python Int,
    Company_ID INT,
    Location_ID INT,
    Industry_ID INT,
    FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID),
    FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID),
    FOREIGN KEY (Industry_ID) REFERENCES Industry(Industry_ID)
);
-- Each post will have its own ID (job_id), along with the title, avg salary information.
-- Adding in the company, location, and industry    
-- Each job posting belongs to an :
-- industry and Industry_ID 
-- company and company_id
-- locatin and location_id


INSERT INTO Job_Postings (Title, Avg_Salary, Job_Description, r_lang, python, Company_ID, Location_ID, Industry_ID) 
SELECT distinct d.job_title, d.avg_salary, d.job_description, d.r_lang, d.python, c.Company_ID, l.Location_ID, i.Industry_ID 
FROM glassdoor_clean d 
JOIN Company c ON d.company_name = c.Company_Name 
JOIN Location l ON d.city = l.City AND d.state = l.State 
JOIN Industry i ON d.industry = i.Industry_Name; 