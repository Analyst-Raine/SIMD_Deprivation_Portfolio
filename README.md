# SIMD & Deprivation Analysis — Scotland (Case Study: Aberdeen)
## Project Overview

This project investigates deprivation patterns in Aberdeen, Scotland using the Scottish Index of Multiple Deprivation (SIMD 2020) dataset.

The goal is to evaluate:

* How Aberdeen compares to national deprivation patterns

* Which domains (housing, crime, education, etc.) drive local inequality

* Where Aberdeen is better or worse than Scotland on average

This is a portfolio project to demonstrate skills — not academic research.

## Tools Used
### Tool -  Purpose
* R / RStudio - 	Data wrangling, cluster analysis, interpretation
* K-Means (k=4) - 	Grouping Data Zones by deprivation similarity
* QGIS	- Mapping spatial outputs & cluster patterns


## Data

Source: SIMD 2020 — Data Zone Level (Scotland)

7 Domains Used

* Income

* Employment

* Health

* Education

* Access to Services

* Crime

* Housing

Important Ranking Rule

Higher Rank     = Lower Deprivation (Better Off)
Lower Rank      = Higher Deprivation (Worse Off)

## Method

Load SIMD dataset & retain relevant indicators

Standardise values (scale) for clustering

Run K-Means with k = 4 for:

Scotland (baseline patterns)

Aberdeen (local patterns)

Join clusters back to spatial data

Calculate % differences → Aberdeen vs Scotland

Export maps (GeoPackage) & insights

## Cluster Labels
Cluster	Label	Meaning
* 1	Low Deprivation - 	Affluent, strong across domains, slightly lower on access
* 2	Moderate Urban Deprivation- Middle-range urban outcomes
* 3	High Urban Deprivation	- Severe deprivation across domains
* 4	Mixed Urban Deprivation	- Uneven profile; fluctuating strengths

These are interpretation labels, not official SIMD classifications.

Key Results
## Finding 1: Aberdeen vs Scotland — Summary
### Domain	Aberdeen vs Scotland	Summary
* Income:	Mixed but mostly better - 	Stronger earnings & workforce profile
* Employment:	Better in most clusters	- Job market resilience
* Health: 	Better in affluent area worse in deprived areas	- Urban health inequality
* Education: 	Slightly stronger	- slightly worse in deprived areas
* Access:	Better in every cluster	- Transport/service access not a barrier
* Crime: Worse in high-deprivation areas	- Urban pressure effects
* Housing: 	Consistently worse-	Most significant deprivation driver

## Finding 2 — What Drives Deprivation in Aberdeen

<img src = "Maps/Housing.pdf

### Aberdeen's deprivation pattern is different from national structure:

Key Drivers of Deprivation
* Housing Inequality -	Systematically worse than Scotland across all clusters
* Urban Health Outcomes	- Sharp health gaps in deprived zones
* Concentrated Urban Deprivation - High deprivation cluster significantly lower ranked

### Not key drivers (in Aberdeen):

* Geography

* Transport / Access

* Rural isolation

## Finding 3 — Access Insight

Aberdeen is better than Scotland for access to services in every cluster.

This contradicts common assumptions about northern/peripheral cities and shows strong local infrastructure & public service provision.

## Conclusion

* Aberdeen’s deprivation is driven by urban inequality, not geography.

* Strong polarisation between affluent & deprived zones

* Some areas exceed national outcomes — others fall far below

* Housing is the clearest intervention opportunity

  
