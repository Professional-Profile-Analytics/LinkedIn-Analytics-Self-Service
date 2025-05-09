#!/usr/bin/env Rscript

#' LinkedIn Analytics Data Analysis
#' 
#' This script analyzes LinkedIn analytics data exported from your profile.
#' 
#' Requirements:
#' - tidyverse
#' - readxl
#' - lubridate
#' - ggplot2
#' - scales
#' 
#' Usage:
#' 1. Export your LinkedIn analytics data as an XLSX file
#' 2. Update the file_path variable below to point to your XLSX file
#' 3. Run the script: Rscript linkedin_analytics.R

# Load required libraries
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("readxl")) install.packages("readxl")
if (!require("lubridate")) install.packages("lubridate")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("scales")) install.packages("scales")

library(tidyverse)
library(readxl)
library(lubridate)
library(ggplot2)
library(scales)

# Set file path to your LinkedIn analytics XLSX file
file_path <- "LinkedIn_Analytics.xlsx"

# Function to load all sheets from Excel file
load_analytics_data <- function(file_path) {
  tryCatch({
    # Get all sheet names
    sheet_names <- excel_sheets(file_path)
    
    # Create a named list to store each sheet as a dataframe
    data <- list()
    
    for (sheet in sheet_names) {
      data[[sheet]] <- read_excel(file_path, sheet = sheet)
      cat(sprintf("Loaded sheet: %s with %d rows\n", sheet, nrow(data[[sheet]])))
    }
    
    return(data)
  }, error = function(e) {
    cat(sprintf("Error loading data: %s\n", e$message))
    return(NULL)
  })
}

# Function to analyze profile views
analyze_profile_views <- function(profile_views_df) {
  if (is.null(profile_views_df) || nrow(profile_views_df) == 0) {
    return("No profile views data available for analysis.")
  }
  
  # Identify date column
  date_col <- names(profile_views_df)[grep("date", tolower(names(profile_views_df)))]
  
  if (length(date_col) > 0) {
    # Convert date column to Date type
    profile_views_df[[date_col[1]]] <- as.Date(profile_views_df[[date_col[1]]])
    
    # Group by date and count views
    views_by_date <- profile_views_df %>%
      group_by(!!sym(date_col[1])) %>%
      summarise(views = n())
    
    # Create a plot
    p <- ggplot(views_by_date, aes(x = !!sym(date_col[1]), y = views)) +
      geom_line(color = "#0077B5", size = 1) +
      geom_point(color = "#0077B5", size = 3) +
      labs(
        title = "LinkedIn Profile Views Over Time",
        x = "Date",
        y = "Number of Views"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10)
      )
    
    # Save the plot
    ggsave("profile_views_trend.png", p, width = 10, height = 6, dpi = 300)
    cat("Profile views trend chart saved as 'profile_views_trend.png'\n")
    
    # Basic statistics
    total_views <- nrow(profile_views_df)
    
    # Analyze viewer companies if available
    if ("Company" %in% names(profile_views_df)) {
      top_companies <- profile_views_df %>%
        count(Company, sort = TRUE) %>%
        head(10)
      
      cat("\nTop Companies Viewing Your Profile:\n")
      print(top_companies)
      
      # Create a bar chart of top companies
      p_companies <- ggplot(top_companies, aes(x = reorder(Company, n), y = n)) +
        geom_bar(stat = "identity", fill = "#0077B5") +
        coord_flip() +
        labs(
          title = "Top Companies Viewing Your Profile",
          x = "Company",
          y = "Number of Views"
        ) +
        theme_minimal()
      
      ggsave("top_companies.png", p_companies, width = 10, height = 6, dpi = 300)
      cat("Top companies chart saved as 'top_companies.png'\n")
    }
  }
}

# Function to analyze post engagement
analyze_post_engagement <- function(posts_df) {
  if (is.null(posts_df) || nrow(posts_df) == 0) {
    return("No post engagement data available for analysis.")
  }
  
  # Identify engagement columns (likes, comments, shares, etc.)
  engagement_patterns <- c("like", "comment", "share", "click", "impression")
  engagement_cols <- names(posts_df)[sapply(names(posts_df), function(col) {
    any(sapply(engagement_patterns, function(pattern) grepl(pattern, tolower(col))))
  })]
  
  if (length(engagement_cols) > 0) {
    # Calculate total engagement by post
    posts_df$total_engagement <- rowSums(posts_df[engagement_cols], na.rm = TRUE)
    
    # Sort by engagement
    top_posts <- posts_df %>%
      arrange(desc(total_engagement)) %>%
      head(5)
    
    cat("\nYour Top 5 Performing Posts:\n")
    for (i in 1:nrow(top_posts)) {
      post <- top_posts[i, ]
      content_col <- intersect(c("Content", "Post", "Text"), names(post))
      date_col <- intersect(c("Date", "Posted on"), names(post))
      
      cat(sprintf("%d. Date: %s\n", i, if(length(date_col) > 0) post[[date_col[1]]] else "N/A"))
      if (length(content_col) > 0) {
        content <- post[[content_col[1]]]
        if (nchar(content) > 100) content <- paste0(substr(content, 1, 100), "...")
        cat(sprintf("   Content: %s\n", content))
      }
      cat(sprintf("   Total Engagement: %d\n", post$total_engagement))
      
      engagement_breakdown <- sapply(engagement_cols, function(col) sprintf("%s: %d", col, post[[col]]))
      cat(sprintf("   Breakdown: %s\n\n", paste(engagement_breakdown, collapse = ", ")))
    }
    
    # Create visualization of engagement distribution
    engagement_summary <- posts_df %>%
      summarise(across(all_of(engagement_cols), sum, na.rm = TRUE)) %>%
      pivot_longer(cols = everything(), names_to = "Metric", values_to = "Count")
    
    p_engagement <- ggplot(engagement_summary, aes(x = reorder(Metric, Count), y = Count)) +
      geom_bar(stat = "identity", fill = "#0077B5") +
      coord_flip() +
      labs(
        title = "LinkedIn Engagement Metrics Distribution",
        x = "Engagement Type",
        y = "Count"
      ) +
      theme_minimal()
    
    ggsave("engagement_distribution.png", p_engagement, width = 10, height = 6, dpi = 300)
    cat("Engagement distribution chart saved as 'engagement_distribution.png'\n")
  }
}

# Main function
main <- function() {
  cat("LinkedIn Analytics Data Analyzer (R)\n")
  cat("==================================\n")
  
  # Load data
  data <- load_analytics_data(file_path)
  if (is.null(data)) {
    cat("Could not load analytics data. Please check the file path.\n")
    return()
  }
  
  # Analyze different aspects of the data based on sheet names
  for (sheet_name in names(data)) {
    cat(sprintf("\n\nAnalyzing %s...\n", sheet_name))
    df <- data[[sheet_name]]
    
    if (any(grepl("profile|view", tolower(sheet_name)))) {
      analyze_profile_views(df)
    } else if (any(grepl("post|article|engagement", tolower(sheet_name)))) {
      analyze_post_engagement(df)
    }
  }
  
  cat("\n\nThis analysis is powered by a basic implementation.\n")
  cat("For more advanced analytics, visit Professional Profile Analytics (PPA).\n")
}

# Run the main function
main()
