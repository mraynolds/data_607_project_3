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
         "Type_of_ownership",
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
                  same_state,
                  python_yn, 
                  r_yn, 
                  spark, 
                  aws, 
                  excel), 
                parse_number))

# Replace revenue value of '-1' with 'Unknown / Non-Applicable' to not interfere with grouping
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(revenue = ifelse(revenue == "-1" | revenue == "Unknown / Non-Applicable", NA, revenue))

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
      grepl("analyst", job_title, ignore.case = TRUE) ~ "Analyst/Scientist",
    grepl("engineer", job_title, ignore.case = TRUE) ~ "Engineer",
    grepl("analyst", job_title, ignore.case = TRUE) |
      grepl("analytics", job_title, ignore.case = TRUE) ~ "Analyst",  
    grepl("scientist", job_title, ignore.case = TRUE) |
      grepl("science", job_title, ignore.case = TRUE) ~ "Scientist", 
    TRUE ~ NA_character_ 
  ))

# Convert binary skill and tool indicators to logical
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(
    same_state = as.logical(same_state),
    python = as.logical(python),
    r = as.logical(r),
    spark = as.logical(spark),
    aws = as.logical(aws),
    excel = as.logical(excel)
  )

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

# Select and reorder columns for readability
glassdoor_data2 <- glassdoor_data2 |> 
  select(job_id, 
         job_title, 
         job_type, 
         avg_salary_range, 
         avg_salary, 
         min_salary, 
         max_salary, 
         python,
         r,
         spark,
         aws,
         excel,
         city, 
         state, 
         country,
         company_name,
         revenue,
         size,
         type_of_ownership,
         industry,
         sector
  )
           
# eliminate the one nonsense job title
glassdoor_data2 <- glassdoor_data2 |> filter(job_title != "sg nsjx nm/.;'" )

# replace all "unkown" with NA}
glassdoor_data2 <- glassdoor_data2 |> 
  mutate(size = na_if(size,"Unknown"),
         size = na_if(size, "-1"))

# revenue types
glassdoor_data2 |> count(size)

# create factors for avg_salary_range, revenue, and size. Then convert to factors}
avg_salary_levels <- c("0-25000", "25000-50000", "50000-75000", 
                       "75000-100000", "100000-125000", "125000-150000", 
                       "150000-175000", "175000-200000", "200000-225000", 
                       "225000-250000", "250000+")

revenue_levels <- c("Less than $1 million (USD)", " $1 to $5 million (USD)", 
                    "$5 to $10 million (USD)", " $10 to $25 million (USD)",
                    "$25 to $50 million (USD)", "$50 to $100 million (USD)",
                    "$100 to $500 million (USD)", "$500 million to $1 billion (USD)",
                    "$1 to $2 billion (USD)", "$2 to $5 billion (USD)", "$5 to $10 billion (USD)",
                    "$10+ billion (USD)")

size_levels <- c("1 to 50 employees","51 to 200 employees","201 to 500 employees",
          "501 to 1000 employees","1001 to 5000 employees", "5001 to 10000 employees",
          "10000+ employees")

glassdoor_data2 <- glassdoor_data2 |> mutate(
  avg_salary_range = factor(avg_salary_range, levels = avg_salary_levels),
  revenue = factor(revenue, levels = revenue_levels),
  size = factor(size, levels = size_levels)
)

# count ownership types
glassdoor_data2 |> count(type_of_ownership)
