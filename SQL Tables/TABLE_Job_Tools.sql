USE data607_database;

drop table job_tools;

CREATE TABLE Job_Tools ( 
    Job_ID INT, 
    Tool_ID INT, 
    PRIMARY KEY (Job_ID, Tool_ID), 
    FOREIGN KEY (Job_ID) REFERENCES Job_Postings(Job_ID) ON DELETE CASCADE, 
    FOREIGN KEY (Tool_ID) REFERENCES Tools(Tool_ID) ON DELETE CASCADE 

); 
-- Each Job posting will have multiple skill_id as one job can have multiple skills required. 
-- Adding in the reference for Job_ID and SKill_ID  


CREATE TEMPORARY TABLE Temp_Extracted_tools AS
SELECT g.Job_ID, t.tool_ID, t.tool_name
FROM job_postings g
JOIN tools t 
On LOWER(g.job_description) LIKE CONCAT('%', LOWER(t.tool_Name), '%')

UNION

SELECT g.Job_ID, t.tool_ID, t.tool_Name
FROM job_postings g
JOIN tools t
ON (
   g.spark = 1 AND t.tool_name = 'Spark' OR
    g.aws = 1 AND t.tool_name = 'aws' OR
    g.excel = 1 AND t.tool_name = 'excel');

    
-- temp table to extract skills

INSERT INTO Job_tools (Job_ID, Tool_ID)
SELECT te.Job_ID, te.Tool_ID
FROM Temp_Extracted_Tools te
JOIN job_postings jp ON te.Job_ID = jp.Job_ID;

