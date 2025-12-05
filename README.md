# F1 Data Engineering Project

[![Snowflake](https://img.shields.io/badge/Snowflake-2C9DCB?style=for-the-badge&logo=Snowflake&logoColor=white)](https://www.snowflake.com)
[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/)
[![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![Formula 1](https://img.shields.io/badge/formula%201-%23E10600.svg?style=for-the-badge&logo=formula1&logoColor=white)](https://www.formula1.com)

## Project Overview

This is a Data Engineering hobby project focused on analyzing Formula 1 telemetry and race data. The primary goal is to build an automated pipeline that ingests race data, transforms it within a modern data warehouse, and visualizes a **2025 Championship Leaderboard** directly within Snowflake.

The project utilizes the **[OpenF1 API](https://api.openf1.org)** as the primary data source.

---

## Architecture

The project follows an **ELT (Extract, Load, Transform)** pattern, leveraging Snowflake's native capabilities for transformation and hosting the application.

```mermaid
graph LR
    A[OpenF1 API] -->|JSON| B(Python)
    B -->|Ingest| C[(Snowflake RAW)]
    
    subgraph Snowflake Data Cloud
        C -->|Streams/Tasks| D[Dynamic Tables \n Transformation Layer]
        D -->|Joins & Aggregates| E[Data Mart Views]
        E -->|Select| F[Streamlit in Snowflake]
    end
