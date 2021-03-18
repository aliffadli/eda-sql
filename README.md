# Hello!

This project is part of the course I attended on [DataCamp](https://learn.datacamp.com/courses/exploratory-data-analysis-in-sql).
This is an exploratory data analysis project with SQL. This project contains a table such as: stack overflow question counts, fortune 500 companies, and evanston 311 help requests. Most of the table I mentioned before, have a relationship with each other. Therefore creating an Entity Relationship Diagram (ERD). This ERD will play a part of my analysis, mainly when I joining some particular table. Below is the ERD of this project to help you understand of my query.

![erdiagram](https://user-images.githubusercontent.com/43002414/111296097-abb99680-867e-11eb-8d62-5761113b0ea5.png)

Before starting with this project, you must create and insert values into the database. To do that, first you must run the specific query for creating the tables and inserting the values. I already saved those query on [eda-sql/create_database.sql](https://github.com/aliffadli/eda-sql/blob/main/create_database.sql) for you to run it. After that, you can play with all of my other scripts whichever you want. 

To see what is the purpose of each script, read the explanation below: 
1. [see_database.sql](https://github.com/aliffadli/eda-sql/blob/main/see_database.sql). This script is used for exploring a database by identifying the tables and the foreign keys that link them. Look for missing values, count the number of observations, and join tables to understand how they're related. 
2. [aggregation.sql](https://github.com/aliffadli/eda-sql/blob/main/aggregation.sql). This script is used for summarize numeric data.
3. [categorical_unstructured.sql](https://github.com/aliffadli/eda-sql/blob/main/categorical_unstructured.sql). This script is used to deal with inconsistencies in case, spacing, and delimiters; using a temporary table to recode messy categorical data to standardized values you can count and aggregate; and then, extract new variables from unstructured text. 
4. [dates_times.sql](https://github.com/aliffadli/eda-sql/blob/main/dates_times.sql). This script is used for analyzing dates and times of the databases. 

# Thank you!

