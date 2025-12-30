# ============================
# SIMD Clustering Project
# ============================

# Load libraries
library (tidyverse)
library(sf)
library(dplyr)
library(factoextra)
library(knitr)
library(kableExtra)
library (ggplot2)

# ----------------------------
# 1. Load SIMD shapefile
# ----------------------------
simd_data <- st_read("scottish deprivation atlas/raw data/SG_SIMD_2020/SG_SIMD_2020.shp")



# Inspect
glimpse(simd_data)
print(names(simd_data))

# ----------------------------
# 2. Prepare working data (numeric only for clustering)
# ----------------------------
working_data <- simd_data %>%
  st_drop_geometry() %>% # drop geometries to allow ease of computation
  transmute( # remane columns and keep only the ones listed
    DataZone = DataZone,    # keep this it will be used for the join      
    SIMD_Rank = Rankv2,
    SIMD_Quintile = Quintilev2,
    SIMD_Percentile = Percentv2,
    Income_Rank = IncRankv2,
    Employment_Rank = EmpRank,
    Health_Rank = HlthRank,
    Education_Rank = EduRank,
    Access_Rank = GAccRank,
    Crime_Rank = CrimeRank,
    Housing_Rank = HouseRank
  )

numeric_data <- working_data %>% select(-DataZone) # select just the numerics

# ----------------------------
# 3. Determine optimal clusters (Elbow method)
# ----------------------------
set.seed(123)
fviz_nbclust(scale(numeric_data), kmeans, method = "wss") +
  labs(subtitle = "Elbow Method") # we need to know the optimal clusters
# 2 was recommended but i used 4

# ----------------------------
# 4. K-means clustering
# ----------------------------
set.seed(123)
# 4 clusters, standardise the data using scale, run the algo 25 times
kmeans_result <- kmeans(scale(numeric_data), centers = 4, nstart = 25)

# Add cluster numbers and labels
working_data$Cluster <- kmeans_result$cluster
working_data$Cluster_Label <- factor(
  working_data$Cluster,
  levels = 1:4,
  labels = c(
    "Low Deprivation",
    "Moderate Urban Deprivation",
    "High Urban Deprivation",
    "Mixed Urban Deprivation"
  )
)

# ----------------------------
# 5. Scotland-wide cluster summary
# ----------------------------

# Group working data by the clusters created earlier and the names
# summarise across the columns, by taking the mean of each column and creates a
# new column called avg_ the original column name
cluster_summary <- working_data %>%
  group_by(Cluster, Cluster_Label) %>%
  summarise(across(Income_Rank:Housing_Rank, mean, .names = "avg_{.col}"))
kable(cluster_summary) %>%
  kable_paper()
  
kable(prop.table(table(cluster_summary$Cluster_Label)) * 100)


# ----------------------------
# 6. Join clusters back to spatial dataset (KEEP GEOMETRY)
# ----------------------------

# keep all rows in smid_data and only bring matching rows from working data
# Datazone is the key
sd_clusters <- simd_data %>%
  left_join(working_data, by = "DataZone")  # Include numeric columns + clusters

# ----------------------------
# 7. Extract Aberdeen case study
# ----------------------------
aberdeen <- simd_clusters %>%
  filter(LAName == "Aberdeen City")

aberdeen_summary <- aberdeen %>%
  st_drop_geometry() %>%
  group_by(Cluster, Cluster_Label) %>%
  summarise(across(Income_Rank:Housing_Rank, mean, .names = "avg_{.col}"))
kable(aberdeen_summary) %>%
  kable_paper()


# Cluster distribution in Aberdeen
table(aberdeen$Cluster)
kable(prop.table(table(aberdeen$Cluster_Label)) * 100)

# ----------------------------
# 8. Create Comparsion Table
# ----------------------------

comparison_table <- cluster_summary %>%
  rename_with(~paste0("Scotland_", .), -c(Cluster, Cluster_Label)) %>%
  left_join(
    aberdeen_summary %>%
      rename_with(~paste0("Aberdeen_", .), -c(Cluster, Cluster_Label)),
    by = c("Cluster", "Cluster_Label")
  )

kable(comparison_table) %>%
  kable_paper()



comparison_pct <- cluster_summary %>%
  rename_with(~paste0("Scotland_", .), -c(Cluster, Cluster_Label)) %>%
  left_join(
    aberdeen_summary %>%
      rename_with(~paste0("Aberdeen_", .), -c(Cluster, Cluster_Label)),
    by = c("Cluster", "Cluster_Label")
  ) %>%
  # percentage difference = (Aberdeen - Scotland) / Scotland * 100
  transmute(
    Label = Cluster_Label,
    PercDiff_Income = (Aberdeen_avg_Income_Rank - Scotland_avg_Income_Rank) / Scotland_avg_Income_Rank * 100,
    PercDiff_Employment = (Aberdeen_avg_Employment_Rank - Scotland_avg_Employment_Rank) / Scotland_avg_Employment_Rank * 100,
    PercDiff_Health = (Aberdeen_avg_Health_Rank - Scotland_avg_Health_Rank) / Scotland_avg_Health_Rank * 100,
    PercDiff_Education = (Aberdeen_avg_Education_Rank - Scotland_avg_Education_Rank) / Scotland_avg_Education_Rank * 100,
    PercDiff_Access = (Aberdeen_avg_Access_Rank - Scotland_avg_Access_Rank) / Scotland_avg_Access_Rank * 100,
    PercDiff_Crime = (Aberdeen_avg_Crime_Rank - Scotland_avg_Crime_Rank) / Scotland_avg_Crime_Rank * 100,
    PercDiff_Housing = (Aberdeen_avg_Housing_Rank - Scotland_avg_Housing_Rank) / Scotland_avg_Housing_Rank * 100
  )

comparison_pct

kable(comparison_pct <- comparison_pct %>%
        mutate(across(starts_with("PercDiff"), ~round(.x, 2)))) %>%
  kable_styling()



ggplot(comparison_pct, aes(x = Label, y = PercDiff_Housing, fill = Cluster)) +
  geom_col() +
  labs(title = "Aberdeen Housing Deprivation vs Scotland by Cluster",
       y = "% Higher Housing Deprivation than Scotland",
       x = "Cluster Type")


# ----------------------------
# 9. Export shapefiles (geometry intact)
# ----------------------------


#GeoPackage export to preserve longer field names
st_write(smid_clusters, "scottish deprivation atlas/outputs/simd_clusters_scotland.gpkg", delete_dsn = TRUE)
st_write(aberdeen, "scottish deprivation atlas/outputs/aberdeen_clusters.gpkg", delete_dsn = TRUE)


 # create plots

# Add a column to identify the location
scotland_long <- cluster_summary %>%
  mutate(Location = "Scotland") %>%
  pivot_longer(cols = starts_with("avg_"), 
               names_to = "Domain", 
               values_to = "Value") %>%
  mutate(Domain = gsub("avg_", "", Domain))

aberdeen_long <- aberdeen_summary %>%
  mutate(Location = "Aberdeen") %>%
  pivot_longer(cols = starts_with("avg_"), 
               names_to = "Domain", 
               values_to = "Value") %>%
  mutate(Domain = gsub("avg_", "", Domain))

combined <- bind_rows(scotland_long, aberdeen_long)

ggplot(combined, aes(x = Domain, y = Value, fill = Location)) +
  geom_col(position = "dodge") +
  facet_wrap(~Cluster_Label) +
  scale_fill_manual(values = c("Scotland" = "#11577a", "Aberdeen" = "#ad3027")) +
  labs(title = "Scotland vs Aberdeen by Domain and Cluster",
       y = "Average Rank (Higher = Better)",
       x = "Domain") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



