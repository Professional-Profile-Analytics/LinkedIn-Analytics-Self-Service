#!/usr/bin/env python3
"""
LinkedIn Analytics Data Analysis
-------------------------------
This script analyzes LinkedIn analytics data exported from your profile.

Requirements:
- pandas
- matplotlib
- seaborn
- openpyxl

Usage:
1. Export your LinkedIn analytics data as an XLSX file
2. Update the file_path variable below to point to your XLSX file
3. Run the script: python linkedin_analytics.py
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import os

def load_analytics_data(file_path):
    """Load LinkedIn analytics data from XLSX file"""
    try:
        # Read all sheets from the Excel file
        xl = pd.ExcelFile(file_path)
        
        # Create a dictionary to store each sheet as a dataframe
        data = {}
        for sheet_name in xl.sheet_names:
            data[sheet_name] = pd.read_excel(file_path, sheet_name=sheet_name)
            print(f"Loaded sheet: {sheet_name} with {len(data[sheet_name])} rows")
        
        return data
    except FileNotFoundError:
        print(f"Error: File {file_path} not found.")
        return None
    except Exception as e:
        print(f"Error loading data: {e}")
        return None

def analyze_profile_views(profile_views_df):
    """Analyze profile views data"""
    if profile_views_df is None or len(profile_views_df) == 0:
        return "No profile views data available for analysis."
    
    # Convert date column to datetime if needed
    date_col = [col for col in profile_views_df.columns if 'date' in col.lower()][0]
    profile_views_df[date_col] = pd.to_datetime(profile_views_df[date_col])
    
    # Group by date and count views
    views_by_date = profile_views_df.groupby(date_col).size().reset_index(name='views')
    
    # Create a plot
    plt.figure(figsize=(12, 6))
    plt.plot(views_by_date[date_col], views_by_date['views'], marker='o')
    plt.title('LinkedIn Profile Views Over Time')
    plt.xlabel('Date')
    plt.ylabel('Number of Views')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    
    # Save the plot
    plt.savefig('profile_views_trend.png')
    print("Profile views trend chart saved as 'profile_views_trend.png'")
    
    # Basic statistics
    total_views = profile_views_df.shape[0]
    unique_viewers = profile_views_df['Profile viewer'].nunique() if 'Profile viewer' in profile_views_df.columns else "N/A"
    
    # Analyze viewer companies if available
    if 'Company' in profile_views_df.columns:
        top_companies = profile_views_df['Company'].value_counts().head(10)
        print("\nTop Companies Viewing Your Profile:")
        print(top_companies)
    
    # Analyze viewer job titles if available
    if 'Job title' in profile_views_df.columns:
        top_titles = profile_views_df['Job title'].value_counts().head(10)
        print("\nTop Job Titles Viewing Your Profile:")
        print(top_titles)
    
    return {
        "total_views": total_views,
        "unique_viewers": unique_viewers
    }

def analyze_post_engagement(posts_df):
    """Analyze post engagement data"""
    if posts_df is None or len(posts_df) == 0:
        return "No post engagement data available for analysis."
    
    # Identify engagement columns (likes, comments, shares, etc.)
    engagement_cols = [col for col in posts_df.columns if any(metric in col.lower() 
                                                            for metric in ['like', 'comment', 'share', 'click', 'impression'])]
    
    # Calculate total engagement by post
    if engagement_cols:
        posts_df['total_engagement'] = posts_df[engagement_cols].sum(axis=1)
        
        # Sort by engagement
        top_posts = posts_df.sort_values('total_engagement', ascending=False).head(5)
        
        print("\nYour Top 5 Performing Posts:")
        for i, (idx, post) in enumerate(top_posts.iterrows(), 1):
            print(f"{i}. Date: {post.get('Date', 'N/A')}")
            print(f"   Content: {post.get('Content', post.get('Post', 'N/A'))[:100]}...")
            print(f"   Total Engagement: {post['total_engagement']}")
            print(f"   Breakdown: {', '.join([f'{col}: {post[col]}' for col in engagement_cols])}")
            print()
    
    # Create visualization of post performance over time
    if 'Date' in posts_df.columns and engagement_cols:
        posts_df['Date'] = pd.to_datetime(posts_df['Date'])
        plt.figure(figsize=(14, 7))
        
        for col in engagement_cols:
            plt.plot(posts_df['Date'], posts_df[col], marker='o', label=col)
            
        plt.title('LinkedIn Post Engagement Over Time')
        plt.xlabel('Date')
        plt.ylabel('Engagement Count')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        
        # Save the plot
        plt.savefig('post_engagement_trend.png')
        print("Post engagement trend chart saved as 'post_engagement_trend.png'")

def main():
    print("LinkedIn Analytics Data Analyzer")
    print("===============================")
    
    # Update this path to your LinkedIn analytics XLSX file
    file_path = "LinkedIn_Analytics.xlsx"
    
    # Load data
    data = load_analytics_data(file_path)
    if not data:
        print("Could not load analytics data. Please check the file path.")
        return
    
    # Analyze different aspects of the data based on sheet names
    for sheet_name, df in data.items():
        print(f"\n\nAnalyzing {sheet_name}...")
        
        if any(term in sheet_name.lower() for term in ['profile', 'view']):
            results = analyze_profile_views(df)
            if isinstance(results, dict):
                print(f"Total profile views: {results['total_views']}")
                print(f"Unique viewers: {results['unique_viewers']}")
        
        elif any(term in sheet_name.lower() for term in ['post', 'article', 'engagement']):
            analyze_post_engagement(df)
    
    print("\n\nThis analysis is powered by a basic implementation.")
    print("For more advanced analytics, visit Professional Profile Analytics (PPA).")

if __name__ == "__main__":
    main()
