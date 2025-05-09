# LinkedIn Analytics Analysis with R

This folder contains R scripts to analyze LinkedIn analytics data exported from your profile.

## Getting Started

1. Export your LinkedIn analytics data as described in the main README
2. Install R and the required packages:
   ```R
   install.packages(c("tidyverse", "readxl", "lubridate", "ggplot2", "scales"))
   ```
3. Update the file path in the script to point to your exported XLSX file
4. Run the script to analyze your data

## Example: Profile Views and Post Engagement Analysis

The `linkedin_analytics.R` script provides a comprehensive analysis of your LinkedIn analytics data, including:

- Profile views over time with trend visualization
- Visitor company analysis with bar charts
- Post engagement metrics with distribution analysis
- Top performing content identification
- Visualizations of key metrics

### How to Use

1. Save your LinkedIn analytics XLSX file to your computer
2. Update the `file_path` variable in the script to point to your file
3. Run the script:
   ```
   Rscript linkedin_analytics.R
   ```
   or open it in RStudio and run it from there
4. The script will generate visualizations and print insights to the console

### Sample Output

The script will generate:
- A time series chart of your profile views (`profile_views_trend.png`)
- A bar chart of top companies viewing your profile (`top_companies.png`)
- An engagement distribution chart (`engagement_distribution.png`)
- Console output with detailed analytics and insights

## Sponsored by Professional Profile Analytics

The examples in this repository provide basic analysis capabilities. For more advanced analytics, visualization, and insights, check out [Professional Profile Analytics (PPA)](https://ppa.guide).

PPA helps professionals grow on LinkedIn with:
* AI-powered feedback on your LinkedIn posts
* A personalized content strategy based on your goals and data
* Advanced Analytics and Insights into what drives engagement and reach
* Benchmarks to compare your performance with peers
* A Chrome plugin to automate content upload and analysis
* A content Score
* A tool to validate your content for LinkedIn best practices
