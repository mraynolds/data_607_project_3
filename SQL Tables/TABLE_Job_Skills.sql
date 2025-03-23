USE data607_database;


CREATE TABLE Job_Skills ( 
    Job_ID INT, 
    Skill_ID INT, 
    PRIMARY KEY (Job_ID, Skill_ID), 
    FOREIGN KEY (Job_ID) REFERENCES Job_Postings(Job_ID) ON DELETE CASCADE, 
    FOREIGN KEY (Skill_ID) REFERENCES Skills(Skill_ID) ON DELETE CASCADE 

); 
-- Each Job posting will have multiple skill_id as one job can have multiple skills required. 
-- Adding in the reference for Job_ID and SKill_ID  


CREATE TEMPORARY TABLE Temp_Extracted_skills AS
SELECT g.Job_ID, s.skill_ID, s.skill_name
FROM job_postings g
JOIN skills s 
On LOWER(g.job_description) LIKE CONCAT('%', LOWER(s.skill_Name), '%')

UNION

SELECT g.Job_ID, s.skill_ID, s.skill_Name
FROM job_postings g
JOIN skills s
ON (
    g.r_lang = 1 AND s.skill_name = 'r_lang' OR
    g.python = 1 AND s.skill_name = 'Python');
    
-- temp table to extract skills

INSERT INTO Job_skills (Job_ID, Skill_ID)
SELECT te.Job_ID, te.Skill_ID
FROM Temp_Extracted_skills te
JOIN job_postings jp ON te.Job_ID = jp.Job_ID;

