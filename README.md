## Income Classification Using SAS: A Case Study with 1994 Census Data
This dataset has been taken from the famous UCI Machine Learning Repository. The data in the dataset was extracted from the 1994 Census Bureau. The prediction objective is to determine whether an individual earns more than $50,000 annually.

## Table of Contents
* [File Description](#description)
* [How to access SAS program](#HowtoaccessSASprogram)
* [Results](#Results)

## File Description
The repository contains the following files:

* income_project.sas: This is the main SAS program file that contains the code for data cleaning and analysis.
* rawdata.csv: This is the input dataset file in CSV format.

## How to access SAS program
To access the SAS program for this project, follow these steps:

* Download and install SAS software on your computer.
* Download the income dataset from the repository.
* Open the SAS software and create a new program file.
* Run the program to generate results and analysis.

## Results
I.      Examining categorical variables
* I.1.    Check and Correct Errors when necessary
* I.2.   Check for missing values.
* I.3.   Check for missing values (Informat Method) 
* I.4.Treat missing value 
* I.5.   Create one or more derived variables. 
* I.6.    Combine values in one for a categorical variable.

II.      Examining numerical variables 
* II.1.   Check Errors of Numerical Data 
* II.2.   Correcting Data: Drop variables Fnlwgt, CapitalGain and CapitalLoss
* II.3.   Detect Outliers: Detect outliers based on Histogram and box plot.
* II.4.   Remove Outliers: Remove the outliers. 
* II.5.    Test for normality and plot histogram and QQ plots for "Age" variable with a skewed distribution
* II.6.    Apply a transformation: This step to transform the Age variable to normal distribution
