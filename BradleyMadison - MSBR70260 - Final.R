
#### PACKAGES AND LIBRARIES ####

install.packages('raster')
install.packages('sf')
install.packages('terra')
install.packages('haven')
install.packages('xgboost')
install.packages('survival')
      
# For raster operations
library(raster)

# For spatial vector operations
library(sf)
    
# For additional raster and spatial vector operations
library(terra)
  
# For dta files
library(haven)

# For models
library(xgboost)
library(survival)
library(ggplot2)


#### LAN SET-UP ####

# Let `r_` represent raster files
# Let `shp_` represent shape files
# Let `sp_` represent spatial object files

# Load LAN
raw1 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DMSP-OLS F18 2012/F182012.v4c.global.intercal.stable_lights.avg_vis.tif'
raw2 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DMSP-OLS F18 2013/F182013.v4c.global.intercal.stable_lights.avg_vis.tif'
      
r_stable12 <- raster(raw1)    
r_stable13 <- raster(raw2)

      # View
      plot(r_stable12)
      plot(r_stable13)

# Load country boundaries
raw3 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/NE Country Boundaries/ne_10m_admin_0_countries.shp'
    
shp_countries <- st_read(raw3)

# Review coordinate reference systems (CRS)

      # Review LAN CRS
      # Note: Source lists CRS as EPSG: 4326, verify Proj.4 and WKT2 against https://spatialreference.org/ref/epsg/4326/wkt2.html
      r_stable12_crs <- crs(r_stable12)
      r_stable13_crs <- crs(r_stable13)
        
      # Review country boundaries CRS
      countrybounds_crs <- crs(shp_countries)

# Convert `shp_countries` to spatial object
sp_countries <- as(shp_countries, 'Spatial')

# Crop and mask raster by country boundary
    
      # Subset `shp_countries` to Rwanda and Kenya
      KEN <- shp_countries[(which(shp_countries$SOVEREIGNT == 'Kenya')), ]
      RWA <- shp_countries[(which(shp_countries$SOVEREIGNT == 'Rwanda')), ]

      # Crop LAN by country boundary
      r_stable12_KEN <- crop(r_stable12, KEN)
      r_stable12_RWA <- crop(r_stable12, RWA)
      r_stable13_KEN <- crop(r_stable13, KEN)
      r_stable13_RWA <- crop(r_stable13, RWA)

            # View
            plot(r_stable12_KEN)
            plot(r_stable12_RWA)
            plot(r_stable13_KEN)
            plot(r_stable13_RWA)

      # Mask raster to retain only area within boundaries
      rm_stable12_KEN <- mask(r_stable12_KEN, KEN)
      rm_stable12_RWA <- mask(r_stable12_RWA, RWA)
      rm_stable13_KEN <- mask(r_stable13_KEN, KEN)
      rm_stable13_RWA <- mask(r_stable13_RWA, RWA)

            # View
            plot(rm_stable12_KEN)
            plot(rm_stable12_RWA)
            plot(rm_stable13_KEN)
            plot(rm_stable13_RWA)

      # Validate with country with known boundaries
      USA <- shp_countries[(which(shp_countries$SOVEREIGNT == 'United States of America')), ]
      r_stable12_USA <- crop(r_stable12, USA)
      rm_stable12_USA <- mask(r_stable12_USA, USA)
      plot(rm_stable12_USA)

      # Save to TIFs
      writeRaster(rm_stable12_KEN, 'rm_stable12_KEN.tif')
      writeRaster(rm_stable12_RWA, 'rm_stable12_RWA.tif')
      writeRaster(rm_stable13_KEN, 'rm_stable13_KEN.tif')
      writeRaster(rm_stable13_RWA, 'rm_stable13_RWA.tif')

# Convert to data frames with x, y, values

      # Extract values
      temp_stable12_KEN <- rasterToPoints(rm_stable12_KEN, spatial = TRUE)
      temp_stable12_RWA <- rasterToPoints(rm_stable12_RWA, spatial = TRUE)
      temp_stable13_KEN <- rasterToPoints(rm_stable13_KEN, spatial = TRUE)
      temp_stable13_RWA <- rasterToPoints(rm_stable13_RWA, spatial = TRUE)

      # Convert to data frame
      d_stable12_KEN <- as.data.frame(temp_stable12_KEN)
      d_stable12_RWA <- as.data.frame(temp_stable12_RWA)
      d_stable13_KEN <- as.data.frame(temp_stable13_KEN)
      d_stable13_RWA <- as.data.frame(temp_stable13_RWA)

      # Simplify column names
      colnames(d_stable12_KEN)[1] <- 'values'
      colnames(d_stable12_RWA)[1] <- 'values'
      colnames(d_stable13_KEN)[1] <- 'values'
      colnames(d_stable13_RWA)[1] <- 'values'

      # Review
      summary(d_stable12_KEN)
      summary(d_stable12_RWA)
      summary(d_stable13_KEN)
      summary(d_stable13_RWA)

      # Save to RData files
      save(d_stable12_KEN, file = 'd_stable12_KEN.RData')
      save(d_stable12_RWA, file = 'd_stable12_RWA.RData')
      save(d_stable13_KEN, file = 'd_stable13_KEN.RData')
      save(d_stable13_RWA, file = 'd_stable13_RWA.RData')


#### DHS SET-UP ####

# Load DHS
raw1 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DHS/KEN14/KEBR72DT/KEBR72FL.DTA'
raw2 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DHS/KEN22/KEBR8CDT/KEBR8CFL.DTA'
raw3 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DHS/RWA15/RWBR70DT/RWBR70FL.DTA'
raw4 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DHS/RWA20/RWBR81DT/RWBR81FL.DTA'

raw_br_KEN14 <- read_dta(raw1)    
raw_br_KEN22 <- read_dta(raw2)
raw_br_RWA15 <- read_dta(raw3)    
raw_br_RWA20 <- read_dta(raw4)

# Create `sub1_br_XXXxx`, subsets by year of birth (b2)
sub1_br_KEN14 <- raw_br_KEN14[raw_br_KEN14$b2 == 2012 | raw_br_KEN14$b2 == 2013, ]
sub1_br_KEN22 <- raw_br_KEN22[raw_br_KEN22$b2 == 2012 | raw_br_KEN22$b2 == 2013, ]
sub1_br_RWA15 <- raw_br_RWA15[raw_br_RWA15$b2 == 2012 | raw_br_RWA15$b2 == 2013, ]
sub1_br_RWA20 <- raw_br_RWA20[raw_br_RWA20$b2 == 2012 | raw_br_RWA20$b2 == 2013, ]

      # Review age at death (b6)

            # `Review sub1_br_KEN14`
            # Determination: CLEAN
            table(sub1_br_KEN14$b6)
            sum(sub1_br_KEN14$b6 > 189 & sub1_br_KEN14$b6 < 200, na.rm = T)
            sum(sub1_br_KEN14$b6 > 289 & sub1_br_KEN14$b6 < 300, na.rm = T)
            sum(sub1_br_KEN14$b6 > 305, na.rm = T)

            # Review `sub1_br_KEN22`
            # Determination: 18 instances of child death after the age of five.
            table(sub1_br_KEN22$b6)
            sum(sub1_br_KEN22$b6 > 189 & sub1_br_KEN22$b6 < 200, na.rm = T)
            sum(sub1_br_KEN22$b6 > 289 & sub1_br_KEN22$b6 < 300, na.rm = T)
            sum(sub1_br_KEN22$b6 > 305, na.rm = T)

            # Review `sub1_br_RWA15`
            # Determination: CLEAN
            table(sub1_br_RWA15$b6)
            sum(sub1_br_RWA15$b6 > 189 & sub1_br_RWA15$b6 < 200, na.rm = T)
            sum(sub1_br_RWA15$b6 > 289 & sub1_br_RWA15$b6 < 300, na.rm = T)
            sum(sub1_br_RWA15$b6 > 305, na.rm = T)

            # Review `sub1_br_RWA20`
            # Determination: 5 instances of child death after the age of five.
            table(sub1_br_RWA20$b6)
            sum(sub1_br_RWA20$b6 > 189 & sub1_br_RWA20$b6 < 200, na.rm = T)
            sum(sub1_br_RWA20$b6 > 289 & sub1_br_RWA20$b6 < 300, na.rm = T)
            sum(sub1_br_RWA20$b6 > 305, na.rm = T)
                  
            # Save birth subsets as RData files
            save(sub1_br_KEN14, file = 'sub1_br_KEN14.RData')
            save(sub1_br_KEN22, file = 'sub1_br_KEN22.RData')
            save(sub1_br_RWA15, file = 'sub1_br_RWA15.RData')
            save(sub1_br_RWA20, file = 'sub1_br_RWA20.RData')

# Subset for only required columns (covariates)

      # Where ``v001` is cluster number
      # Where `b2` is year of birth         
      # Where `b6` is age at death
      # Where `v012` is mother's age at birth
      # Where `v463a` is mother's smoking status
      # Where `v106` is mother's highest education level
      # Where `v161` is type of cooking fuel
      # Where `v116` is availability of toilet facilities
      # Where `v113` is source of drinking water
      # Where `v119` is household has: electricity
      # Where `v190` is wealth index
      
      # Create `sub2_br_KEN14`

            # Determine column numbers
            v0 <- which(colnames(sub1_br_KEN14) == 'v001')
            v1 <- which(colnames(sub1_br_KEN14) == 'b2')
            v2 <- which(colnames(sub1_br_KEN14) == 'b6')
            v3 <- which(colnames(sub1_br_KEN14) == 'v012')
            v4 <- which(colnames(sub1_br_KEN14) == 'v463a')
            v5 <- which(colnames(sub1_br_KEN14) == 'v106')
            v6 <- which(colnames(sub1_br_KEN14) == 'v161')
            v7 <- which(colnames(sub1_br_KEN14) == 'v116')
            v8 <- which(colnames(sub1_br_KEN14) == 'v113')
            v9 <- which(colnames(sub1_br_KEN14) == 'v119')
            v10 <- which(colnames(sub1_br_KEN14) == 'v190')

            # Subset
            sub2_br_KEN14 <- sub1_br_KEN14[,c(v0, v1, v2, v3, v4, v5, v6, v7, v8,v9, v10)]

      # Create `sub2_br_KEN22`

            # Determine column numbers
            v0 <- which(colnames(sub1_br_KEN22) == 'v001')
            v1 <- which(colnames(sub1_br_KEN22) == 'b2')
            v2 <- which(colnames(sub1_br_KEN22) == 'b6')
            v3 <- which(colnames(sub1_br_KEN22) == 'v012')
            v4 <- which(colnames(sub1_br_KEN22) == 'v463a')
            v5 <- which(colnames(sub1_br_KEN22) == 'v106')
            v6 <- which(colnames(sub1_br_KEN22) == 'v161')
            v7 <- which(colnames(sub1_br_KEN22) == 'v116')
            v8 <- which(colnames(sub1_br_KEN22) == 'v113')
            v9 <- which(colnames(sub1_br_KEN22) == 'v119')
            v10 <- which(colnames(sub1_br_KEN22) == 'v190')

            # Subset
            sub2_br_KEN22 <- sub1_br_KEN22[,c(v0, v1, v2, v3, v4, v5, v6, v7, v8,v9, v10)]

      # Create `sub2_br_RWA15`

            # Determine column numbers
            v0 <- which(colnames(sub1_br_RWA15) == 'v001')
            v1 <- which(colnames(sub1_br_RWA15) == 'b2')
            v2 <- which(colnames(sub1_br_RWA15) == 'b6')
            v3 <- which(colnames(sub1_br_RWA15) == 'v012')
            v4 <- which(colnames(sub1_br_RWA15) == 'v463a')
            v5 <- which(colnames(sub1_br_RWA15) == 'v106')
            v6 <- which(colnames(sub1_br_RWA15) == 'v161')
            v7 <- which(colnames(sub1_br_RWA15) == 'v116')
            v8 <- which(colnames(sub1_br_RWA15) == 'v113')
            v9 <- which(colnames(sub1_br_RWA15) == 'v119')
            v10 <- which(colnames(sub1_br_RWA15) == 'v190')

            # Subset
            sub2_br_RWA15 <- sub1_br_RWA15[,c(v0, v1, v2, v3, v4, v5, v6, v7, v8,v9, v10)]

      # Create `sub2_br_RWA20`

            # Determine column numbers
            v0 <- which(colnames(sub1_br_RWA20) == 'v001')
            v1 <- which(colnames(sub1_br_RWA20) == 'b2')
            v2 <- which(colnames(sub1_br_RWA20) == 'b6')
            v3 <- which(colnames(sub1_br_RWA20) == 'v012')
            v4 <- which(colnames(sub1_br_RWA20) == 'v463a')
            v5 <- which(colnames(sub1_br_RWA20) == 'v106')
            v6 <- which(colnames(sub1_br_RWA20) == 'v161')
            v7 <- which(colnames(sub1_br_RWA20) == 'v116')
            v8 <- which(colnames(sub1_br_RWA20) == 'v113')
            v9 <- which(colnames(sub1_br_RWA20) == 'v119')
            v10 <- which(colnames(sub1_br_RWA20) == 'v190')

            # Subset
            sub2_br_RWA20 <- sub1_br_RWA20[,c(v0, v1, v2, v3, v4, v5, v6, v7, v8,v9, v10)]

      # Review columns
      labels_KEN14 <- sapply(sub2_br_KEN14, function(x) attr(x, "label"))
      labels_KEN22 <- sapply(sub2_br_KEN22, function(x) attr(x, "label"))
      labels_RWA15 <- sapply(sub2_br_RWA15, function(x) attr(x, "label"))
      labels_RWA20 <- sapply(sub2_br_RWA20, function(x) attr(x, "label"))

      label_verify <- cbind(labels_KEN14, labels_KEN22, labels_RWA15, labels_RWA20)

      # Save covariate subsets as RData files
      save(sub2_br_KEN14, file = 'sub2_br_KEN14.RData')
      save(sub2_br_KEN22, file = 'sub2_br_KEN22.RData')
      save(sub2_br_RWA15, file = 'sub2_br_RWA15.RData')
      save(sub2_br_RWA20, file = 'sub2_br_RWA20.RData')


#### MATCH LAN AND DHS ####

# Match DHS subsets with DHS cluster lat x lon
      
      # Load
      load('sub2_br_KEN14.RData')
      load('sub2_br_KEN22.RData')
      load('sub2_br_RWA15.RData')
      load('sub2_br_RWA20.RData')

      # Load DHS cluster shapefiles
      raw5 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DHS/KEN14/KEGE71FL/KEGE71FL.shp'
      raw6 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DHS/KEN22/KEGE8AFL/KEGE8AFL.shp'
      raw7 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DHS/RWA15/RWGE72FL/RWGE72FL.shp'
      raw8 <- 'C:/Users/mm-br/OneDrive - nd.edu/Documents/Mod 2/2 - Machine Learning/Final Project/DHS/RWA20/RWGE81FL/RWGE81FL.shp'

      shp_KEN14_clusters <- st_read(raw5)
      shp_KEN22_clusters <- st_read(raw6)
      shp_RWA15_clusters <- st_read(raw7)
      shp_RWA20_clusters <- st_read(raw8)

      # Prepare new DHS subsets to receive cluster lat x lon values
      sub3_br_KEN14 <- sub2_br_KEN14
      sub3_br_KEN22 <- sub2_br_KEN22
      sub3_br_RWA15 <- sub2_br_RWA15
      sub3_br_RWA20 <- sub2_br_RWA20

      # Extract DHS cluster lat x lon values for each survey

            # For `sub3_br_KEN14`
            KEN14_matches <- match(sub2_br_KEN14$v001, shp_KEN14_clusters$DHSCLUST)
            sub3_br_KEN14$c_lat <- shp_KEN14_clusters$LATNUM[KEN14_matches]
            sub3_br_KEN14$c_lon <- shp_KEN14_clusters$LONGNUM[KEN14_matches]

            # For `sub3_br_KEN22`
            KEN22_matches <- match(sub2_br_KEN22$v001, shp_KEN22_clusters$DHSCLUST)
            sub3_br_KEN22$c_lat <- shp_KEN22_clusters$LATNUM[KEN22_matches]
            sub3_br_KEN22$c_lon <- shp_KEN22_clusters$LONGNUM[KEN22_matches]

            # For `sub3_br_RWA15`
            RWA15_matches <- match(sub2_br_RWA15$v001, shp_RWA15_clusters$DHSCLUST)
            sub3_br_RWA15$c_lat <- shp_RWA15_clusters$LATNUM[RWA15_matches]
            sub3_br_RWA15$c_lon <- shp_RWA15_clusters$LONGNUM[RWA15_matches]

            # For `sub3_br_RWA20`
            RWA20_matches <- match(sub2_br_RWA20$v001, shp_RWA20_clusters$DHSCLUST)
            sub3_br_RWA20$c_lat <- shp_RWA20_clusters$LATNUM[RWA20_matches]
            sub3_br_RWA20$c_lon <- shp_RWA20_clusters$LONGNUM[RWA20_matches]

      # Save cluster subsets as RData files
      save(sub3_br_KEN14, file = 'sub3_br_KEN14.RData')
      save(sub3_br_KEN22, file = 'sub3_br_KEN22.RData')
      save(sub3_br_RWA15, file = 'sub3_br_RWA15.RData')
      save(sub3_br_RWA20, file = 'sub3_br_RWA20.RData')

# Reorganize DHS subsets by birth year, country
      
      # Load
      load('sub3_br_KEN12.RData')
      load('sub3_br_KEN22.RData')
      load('sub3_br_RWA15.RData')
      load('sub3_br_RWA20.RData')
      
      # For `sub3_br_KEN14`
      sub4_br_KEN12_1 <- zap_labels(sub3_br_KEN14[sub3_br_KEN14$b2 == 2012, ])
      sub4_br_KEN13_1 <- zap_labels(sub3_br_KEN14[sub3_br_KEN14$b2 == 2013, ])
      nrow(sub4_br_KEN12_1) + nrow(sub4_br_KEN13_1) == nrow(sub3_br_KEN14)
            
      # For `sub3_br_KEN22`
      sub4_br_KEN12_2 <- zap_labels(sub3_br_KEN22[sub3_br_KEN22$b2 == 2012, ])
      sub4_br_KEN13_2 <- zap_labels(sub3_br_KEN22[sub3_br_KEN22$b2 == 2013, ])
      nrow(sub4_br_KEN12_2) + nrow(sub4_br_KEN13_2) == nrow(sub3_br_KEN22)
            
      # For `sub3_br_RWA15`
      sub4_br_RWA12_1 <- zap_labels(sub3_br_RWA15[sub3_br_RWA15$b2 == 2012, ])
      sub4_br_RWA13_1 <- zap_labels(sub3_br_RWA15[sub3_br_RWA15$b2 == 2013, ])
      nrow(sub4_br_RWA12_1) + nrow(sub4_br_RWA13_1) == nrow(sub3_br_RWA15)
            
      # For `sub3_br_RWA20`
      sub4_br_RWA12_2 <- zap_labels(sub3_br_RWA20[sub3_br_RWA20$b2 == 2012, ])
      sub4_br_RWA13_2 <- zap_labels(sub3_br_RWA20[sub3_br_RWA20$b2 == 2013, ])
      nrow(sub4_br_RWA12_2) + nrow(sub4_br_RWA13_2) == nrow(sub3_br_RWA20)
            
      # Add survey year column
      sub4_br_KEN12_1$s_year <- "2014"
      sub4_br_KEN13_1$s_year <- "2014"
      sub4_br_KEN12_2$s_year <- "2022"
      sub4_br_KEN13_2$s_year <- "2022"
      sub4_br_RWA12_1$s_year <- "2015"
      sub4_br_RWA13_1$s_year <- "2015"
      sub4_br_RWA12_2$s_year <- "2020"
      sub4_br_RWA13_2$s_year <- "2020"
      
      # Create `sub4_br_XXXxx` (row bind)
      sub4_br_KEN12 <- rbind(sub4_br_KEN12_1, sub4_br_KEN12_2)
      sub4_br_KEN13 <- rbind(sub4_br_KEN13_1, sub4_br_KEN13_2)
      sub4_br_RWA12 <- rbind(sub4_br_RWA12_1, sub4_br_RWA12_2)
      sub4_br_RWA13 <- rbind(sub4_br_RWA13_1, sub4_br_RWA13_2)
            
      # Save year, country subsets as RData files
      save(sub4_br_KEN12, file = 'sub4_br_KEN12.RData')
      save(sub4_br_KEN13, file = 'sub4_br_KEN13.RData')
      save(sub4_br_RWA12, file = 'sub4_br_RWA12.RData')
      save(sub4_br_RWA13, file = 'sub4_br_RWA13.RData')
      
# Match DHS subsets with LAN lat x lon
      
      # Load
      load('sub4_br_KEN12.RData')
      load('sub4_br_KEN13.RData')
      load('sub4_br_RWA12.RData')
      load('sub4_br_RWA13.RData')
      
      load('d_stable12_KEN.RData')
      load('d_stable12_RWA.RData')
      load('d_stable13_KEN.RData')
      load('d_stable13_RWA.RData')
      
      # Create `DN_values_KEN12`
      DN_values_KEN12 <- rep(NA, nrow(sub4_br_KEN12))
      for(i in 1:nrow(sub4_br_KEN12)){
        geo_dist <- sqrt((sub4_br_KEN12$c_lat[i] - d_stable12_KEN$y)^2 +
                           (sub4_br_KEN12$c_lon[i] - d_stable12_KEN$x)^2)
        geo_min <- which.min(geo_dist)
        DN_values_KEN12[i] <- d_stable12_KEN$values[geo_min]
      }
      
            # Review
            summary(DN_values_KEN12)
            summary(d_stable12_KEN$values)
      
      # Create `DN_values_KEN13`
      DN_values_KEN13 <- rep(NA, nrow(sub4_br_KEN13))
      for(i in 1:nrow(sub4_br_KEN13)){
        geo_dist <- sqrt((sub4_br_KEN13$c_lat[i] - d_stable13_KEN$y)^2 +
                           (sub4_br_KEN13$c_lon[i] - d_stable13_KEN$x)^2)
        geo_min <- which.min(geo_dist)
        DN_values_KEN13[i] <- d_stable13_KEN$values[geo_min]
      }
      
            # Review
            summary(DN_values_KEN13)
            summary(d_stable13_KEN$values)
      
      # Create `DN_values_RWA12`
      DN_values_RWA12 <- rep(NA, nrow(sub4_br_RWA12))
      for(i in 1:nrow(sub4_br_RWA12)){
        geo_dist <- sqrt((sub4_br_RWA12$c_lat[i] - d_stable12_RWA$y)^2 +
                           (sub4_br_RWA12$c_lon[i] - d_stable12_RWA$x)^2)
        geo_min <- which.min(geo_dist)
        DN_values_RWA12[i] <- d_stable12_RWA$values[geo_min]
      }
      
            # Review
            summary(DN_values_RWA12)
            summary(d_stable12_RWA$values)
      
      # Create `DN_values_RWA13`
      DN_values_RWA13 <- rep(NA, nrow(sub4_br_RWA13))
      for(i in 1:nrow(sub4_br_RWA13)){
        geo_dist <- sqrt((sub4_br_RWA13$c_lat[i] - d_stable13_RWA$y)^2 +
                           (sub4_br_RWA13$c_lon[i] - d_stable13_RWA$x)^2)
        geo_min <- which.min(geo_dist)
        DN_values_RWA13[i] <- d_stable13_RWA$values[geo_min]
      }
      
            # Review
            summary(DN_values_RWA13)
            summary(d_stable13_RWA$values)
      
      # Create `sub5_br_XXXxx` (column bind)
      sub5_br_KEN12 <- cbind(sub4_br_KEN12, DN_values_KEN12)
      sub5_br_KEN13 <- cbind(sub4_br_KEN13, DN_values_KEN13)
      sub5_br_RWA12 <- cbind(sub4_br_RWA12, DN_values_RWA12)
      sub5_br_RWA13 <- cbind(sub4_br_RWA13, DN_values_RWA13)
      
      # Add country identifier
      sub5_br_KEN12$country <- "KEN"
      sub5_br_KEN13$country <- "KEN"
      sub5_br_RWA12$country <- "RWA"
      sub5_br_RWA13$country <- "RWA"
      
      # Save year, country, light subsets as RData files
      save(sub5_br_KEN12, file = 'sub5_br_KEN12.RData')
      save(sub5_br_KEN13, file = 'sub5_br_KEN13.RData')
      save(sub5_br_RWA12, file = 'sub5_br_RWA12.RData')
      save(sub5_br_RWA13, file = 'sub5_br_RWA13.RData')
      

#### PREP XGBOOST MODEL ####

# Prepare age_at_death column

      # Load
      load('sub5_br_KEN12.RData')
      load('sub5_br_KEN13.RData')
      load('sub5_br_RWA12.RData')
      load('sub5_br_RWA13.RData')
      
      # For `sub5_br_KEN12`
      temp1 <- str_split(sub5_br_KEN12$b6, "")   

      age_at_death1 <- rep(0, nrow(sub5_br_KEN12))
      for(i in 1:length(temp1)){
        if(length(temp1[[i]]) > 1){
          if(temp1[[i]][1] == 1){
            age_at_death1[i] <- (as.numeric(temp1[[i]][2]) * 10) + as.numeric(temp1[[i]][3])
          } else if (temp1[[i]][1] == 2){
            age_at_death1[i] <- ((as.numeric(temp1[[i]][2]) * 10) + as.numeric(temp1[[i]][3])) * 30
          } else if (temp1[[i]][1] == 3){
            age_at_death1[i] <- ((as.numeric(temp1[[i]][2]) * 10) + as.numeric(temp1[[i]][3])) * 365
          }
        }
   
      }
      
      # For `sub5_br_KEN13`
      temp2 <- str_split(sub5_br_KEN13$b6, "")   
      
      age_at_death2 <- rep(0, nrow(sub5_br_KEN13))
      for(i in 1:length(temp2)){
        if(length(temp2[[i]]) > 1){
          if(temp2[[i]][1] == 1){
            age_at_death2[i] <- (as.numeric(temp2[[i]][2]) * 10) + as.numeric(temp2[[i]][3])
          } else if (temp2[[i]][1] == 2){
            age_at_death2[i] <- ((as.numeric(temp2[[i]][2]) * 10) + as.numeric(temp2[[i]][3])) * 30
          } else if (temp2[[i]][1] == 3){
            age_at_death2[i] <- ((as.numeric(temp2[[i]][2]) * 10) + as.numeric(temp2[[i]][3])) * 365
          }
        }
        
      }
      
      # For `sub5_br_RWA12`
      temp3 <- str_split(sub5_br_RWA12$b6, "")   
      
      age_at_death3 <- rep(0, nrow(sub5_br_RWA12))
      for(i in 1:length(temp3)){
        if(length(temp3[[i]]) > 1){
          if(temp3[[i]][1] == 1){
            age_at_death3[i] <- (as.numeric(temp3[[i]][2]) * 10) + as.numeric(temp3[[i]][3])
          } else if (temp3[[i]][1] == 2){
            age_at_death3[i] <- ((as.numeric(temp3[[i]][2]) * 10) + as.numeric(temp3[[i]][3])) * 30
          } else if (temp3[[i]][1] == 3){
            age_at_death3[i] <- ((as.numeric(temp3[[i]][2]) * 10) + as.numeric(temp3[[i]][3])) * 365
          }
        }
        
      }
      
      # For `sub5_br_RWA13`
      temp4 <- str_split(sub5_br_RWA13$b6, "")   
      
      age_at_death4 <- rep(0, nrow(sub5_br_RWA13))
      for(i in 1:length(temp4)){
        if(length(temp4[[i]]) > 1){
          if(temp4[[i]][1] == 1){
            age_at_death4[i] <- (as.numeric(temp4[[i]][2]) * 10) + as.numeric(temp4[[i]][3])
          } else if (temp4[[i]][1] == 2){
            age_at_death4[i] <- ((as.numeric(temp4[[i]][2]) * 10) + as.numeric(temp4[[i]][3])) * 30
          } else if (temp4[[i]][1] == 3){
            age_at_death4[i] <- ((as.numeric(temp4[[i]][2]) * 10) + as.numeric(temp4[[i]][3])) * 365
          }
        }
        
      }
      
      # Create `sub6_br_XXXxx` (column bind)
      sub6_br_KEN12 <- cbind(sub5_br_KEN12, age_at_death1)
      sub6_br_KEN13 <- cbind(sub5_br_KEN13, age_at_death2)
      sub6_br_RWA12 <- cbind(sub5_br_RWA12, age_at_death3)
      sub6_br_RWA13 <- cbind(sub5_br_RWA13, age_at_death4)
      
      # Review column names and standardize
      colnames(sub6_br_KEN12)
      colnames(sub6_br_KEN13)
      colnames(sub6_br_RWA12)
      colnames(sub6_br_RWA13)
        
      colnames(sub6_br_KEN12)[15] <- 'DN'
      colnames(sub6_br_KEN13)[15] <- 'DN'
      colnames(sub6_br_RWA12)[15] <- 'DN'
      colnames(sub6_br_RWA13)[15] <- 'DN'
          
      colnames(sub6_br_KEN12)[17] <- 'age_at_death'
      colnames(sub6_br_KEN13)[17] <- 'age_at_death'
      colnames(sub6_br_RWA12)[17] <- 'age_at_death'
      colnames(sub6_br_RWA13)[17] <- 'age_at_death'
            
      # Save subsets as RData files
      save(sub6_br_KEN12, file = 'sub6_br_KEN12.RData')
      save(sub6_br_KEN13, file = 'sub6_br_KEN13.RData')
      save(sub6_br_RWA12, file = 'sub6_br_RWA12.RData')
      save(sub6_br_RWA13, file = 'sub6_br_RWA13.RData')
      
# Combine subsets
      
      # Load
      load('sub6_br_KEN12.RData')
      load('sub6_br_KEN13.RData')
      load('sub6_br_RWA12.RData')
      load('sub6_br_RWA13.RData')

      # Combine    
      sub7 <- rbind(sub6_br_KEN12, sub6_br_KEN13, sub6_br_RWA12, sub6_br_RWA13)
      
      # Reformatting
      colnames(sub7)[1] <- 'cluster'
      sub7$cluster <- as.numeric(sub7$cluster)
      
      colnames(sub7)[2] <- 'birth_year'
      sub7$birth_year <- as.factor(sub7$birth_year)
      
      colnames(sub7)[3] <- 'age_at_death_coded'
      sub7$age_at_death_coded <- as.numeric(sub7$age_at_death_coded)
      
      colnames(sub7)[4] <- 'respondent_current_age'
      sub7$respondent_current_age <- as.numeric(sub7$respondent_current_age)
      
      colnames(sub7)[5] <- 'smokes_cigarettes'
      sub7$smokes_cigarettes <- as.factor(sub7$smokes_cigarettes)
      
      colnames(sub7)[6] <- 'highest_ed_level'
      sub7$highest_ed_level <- as.factor(sub7$highest_ed_level)
      
      colnames(sub7)[7] <- 'cooking_fuel'
      sub7$cooking_fuel <- as.factor(sub7$cooking_fuel)
      
      colnames(sub7)[8] <- 'toilet_type'
      sub7$toilet_type <- as.factor(sub7$toilet_type)
      
      colnames(sub7)[9] <- 'water_source'
      sub7$water_source <- as.factor(sub7$water_source)
      
      colnames(sub7)[10] <- 'household_electricity'
      sub7$household_electricity <- as.factor(sub7$household_electricity)
      
      colnames(sub7)[11] <- 'wealth_index'
      sub7$wealth_index <- as.factor(sub7$wealth_index)
      
      colnames(sub7)[14] <- 's_year'
      sub7$s_year <- as.factor(sub7$s_year)
      
      colnames(sub7)[16] <- 'country'
      sub7$country <- as.factor(sub7$country)
      
      # Save as RData file
      save(sub7, file = 'sub7.RData')
      
# Final column preparations
      
      # Load
      load('sub7.RData')
      
      # Create status column
      sub7$status <- ifelse(sub7$age_at_death > 0, '1', '0')
      
      # Drop columns not required for modeling
      sub7 <- sub7[, -c(1, 3, 12, 13)]
      
      # Save as RData file
      model_data <- sub7
      save(model_data, file = 'model_data.RData')


#### RUN XGBOOST MODEL ####

# Load
load('model_data.RData')

# Create feature matrix
features <- fastDummies::dummy_columns(
        model_data, 
        select_columns = c('birth_year', 'smokes_cigarettes', 'highest_ed_level', 'cooking_fuel', 'toilet_type',
                           'water_source', 'household_electricity', 'wealth_index', 's_year', 'country'), 
        remove_first_dummy = TRUE, 
        remove_selected_columns = TRUE
      )

features <- features[, -c(3, 4)]

X <- as.matrix(features)
      
# Create survival object
survival <- Surv(time = model_data$age_at_death, event = model_data$status == '1')

# Extract time and event
time <- survival[, 1]
event <- survival[, 2]

# Parameters for XGBoost with survival analysis support
params <- list(objective = 'survival:cox',
               eval_metric = 'cox-nloglik',
               booster = 'gbtree',
               max_depth = 6,
               eta = 0.1,
               gamma = 0,
               min_child_weight = 1)
      
# Split into training and test sets
set.seed(1123)
train_indices <- sample(1:nrow(X), 0.7 * nrow(X))
X_train <- X[train_indices, ]
y_train_time <- time[train_indices]
y_train_event <- event[train_indices]
X_test <- X[-train_indices, ]
y_test_time <- time[-train_indices]
y_test_event <- event[-train_indices]

# Convert to DMatrix format for XGBoost
dtrain <- xgb.DMatrix(data = X_train, label = y_train_time, missing = NA, 
                      weight = y_train_event)
dtest <- xgb.DMatrix(data = X_test, label = y_test_time, missing = NA, 
                     weight = y_test_event)

# Train the XGBoost model
xgb_model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 100,
  watchlist = list(train = dtrain, eval = dtest),
  early_stopping_rounds = 20,
  verbose = 1,
  print_every_n = 20
)

# Predict on test data
predictions <- predict(xgb_model, dtest, type = "response")
pred_dat <- cbind.data.frame(predictions, y_test_event)

# Plot predicted risk values against light values
temp <- cbind.data.frame(predictions, X_test[,2])
colnames(temp)[2] <- 'DN'
ggplot(temp, aes(x=DN, y = predictions)) + geom_point() + 
  labs(title = 'Risk vs. Light',
       x = 'DN',
       y = 'Mean Predicted Risk Score') + 
  theme_minimal()

# Consider against basic DN vs. age at death
ggplot(model_data, aes(x = DN, y = age_at_death)) + geom_point()

#### COX MODEL ####

# Load
load('model_data.RData')

# Modify status column
model_data$status <- as.numeric(model_data$status)

# Subset for analysis
predictors <- c("DN", "smokes_cigarettes", "highest_ed_level", "cooking_fuel",
                "toilet_type", "water_source", "household_electricity", "wealth_index")
survival <- na.omit(model_data[c("age_at_death", "status", predictors)])

# Fit Cox proportional hazards model
cox_model <- coxph(Surv(age_at_death, status) ~ DN + smokes_cigarettes + highest_ed_level +
                     cooking_fuel + toilet_type + water_source + household_electricity + wealth_index,
                   data = survival)

# Summarize the Cox model
summary(cox_model)

# Generate hazard ratios for a range of DN values
dn_values <- seq(min(survival$DN), max(survival$DN), length.out = 100)
dn_coef <- cox_model$coefficients["DN"]
hr_values <- exp(dn_coef * dn_values)

# Plot the exposure-response curve
exposure_response <- data.frame(DN = dn_values, Hazard_Ratio = hr_values)

ggplot(exposure_response, aes(x = DN, y = Hazard_Ratio)) +
  geom_line(color = "blue") +
  geom_point() +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(title = "Exposure-Response Curve for DN",
       x = "DN",
       y = "Hazard Ratio") +
  theme_minimal()
