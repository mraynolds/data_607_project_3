library(RMySQL)
library(DBI)
library(tidyverse)
library(janitor)

# Connect to the MySQL database
con <- dbConnect(MySQL(), 
                 dbname = "data607_database", 
                 host = "project03.mysql.database.azure.com", 
                 user = "project03", 
                 password = "qL8QjT99dVBi3Q4")

# Retrieve data from the 'glassdoor_data2' table
glassdoor_data2 <- dbGetQuery(con, "SELECT * FROM glassdoor_data2")

# Select relevant columns
glassdoor_data2 <- glassdoor_data2 |> 
  select("Job_id",
         "Job_Title",
         "Size",
         "company_txt",
         "Industry",
         "Sector",
         "Revenue",
         "min_salary",
         "max_salary",
         "avg_salary",
         "City",
         "State",
         "Country",
         "Source",
         "same_state",
         "python_yn",
         "R_yn",
         "spark",
         "aws",
         "excel")

# Clean column names (convert to lowercase)
glassdoor_data2 <- glassdoor_data2 |> 
  clean_names()

# Convert numeric columns from character to numeric format
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(across(c(min_salary, 
                  max_salary, 
                  avg_salary, 
                  python_yn, 
                  r_yn, 
                  spark, 
                  aws, 
                  excel), 
                parse_number))

# Replace revenue value of '-1' with 'Unknown / Non-Applicable' to not interfere with grouping
glassdoor_data2 |> 
  mutate(revenue = ifelse(revenue == "-1", "Unknown / Non-Applicable", revenue))

# Rename columns for better readability
glassdoor_data2 <- glassdoor_data2 |> 
  rename("company_name" = "company_txt",
         "python" = "python_yn",
         "r" = "r_yn")

# Categorize job titles into different job types
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(job_type = case_when(
    grepl("engineer", job_title, ignore.case = TRUE) & 
      grepl("scientist", job_title, ignore.case = TRUE) ~ "Engineer/Scientist",
    grepl("engineer", job_title, ignore.case = TRUE) &
      grepl("analyst", job_title, ignore.case = TRUE) ~ "Engineer/Analyst",
    grepl("scientist", job_title, ignore.case = TRUE) &
      grepl("analyst", job_title, ignore.case = TRUE) ~ "Scientist/Analyst",
    grepl("engineer", job_title, ignore.case = TRUE) ~ "Engineer",
    grepl("analyst", job_title, ignore.case = TRUE) ~ "Analyst",  
    grepl("scientist", job_title, ignore.case = TRUE) ~ "Scientist", 
    TRUE ~ NA_character_ 
  ))

# Convert binary indicators into categorical skill labels in order to tidy into one column
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(python = ifelse(python == "1", "Python", "No"),
         r = ifelse(r == "1", "R", "No")) |> 
  mutate(skill = paste(python, r, sep = ",")) |> 
  mutate(skill = gsub("No,No", "None", skill)) |> 
  separate_rows(skill, sep = ",") |> 
  filter(skill != "No") |> 
  select(-python, 
         -r) |> 
  mutate(skill = na_if(skill, "None"))

# Convert binary indicators into categorical tool labels in order to tidy into one column
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(spark = ifelse(spark == "1", "Spark", "No"),
         aws = ifelse(aws == "1", "AWS", "No"),
         excel = ifelse(excel == "1", "Excel", "No")) |> 
  mutate(tool = paste(spark, aws, excel, sep = ",")) |> 
  mutate(tool = gsub("No,No,No", "None", tool)) |> 
  separate_rows(tool, sep = ",") |> 
  filter(tool != "No") |> 
  select(-spark,
         -aws,
         -excel) |> 
  mutate(tool = na_if(tool, "None"))

# Convert salary figures to full values
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(min_salary = min_salary * 1000) |> 
  mutate(max_salary = max_salary * 1000) |> 
  mutate(avg_salary = avg_salary * 1000)

# Categorize average salary into salary ranges
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(avg_salary_range = cut(avg_salary,
                                breaks = c(0, 
                                           25000, 
                                           50000, 
                                           75000, 
                                           100000, 
                                           125000, 
                                           150000, 
                                           175000, 
                                           200000, 
                                           225000, 
                                           250000, 
                                           275000),
                                labels = c("0-25000", 
                                           "25000-50000", 
                                           "50000-75000", 
                                           "75000-100000", 
                                           "100000-125000", 
                                           "125000-150000", 
                                           "150000-175000", 
                                           "175000-200000", 
                                           "200000-225000", 
                                           "225000-250000", 
                                           "250000+"),
                                right = TRUE))