# ANALYSE GOOGLE JSON FILES
# © 2018 Schule für Gestaltung Bern und Biel
# Philipp Lehmann, philipp@followscontent
#
#

# Load libraries
# --------------
library(jsonlite)
library(maps)
library(maptools)
library(rgdal)



# =============
#   LOAD DATA
# =============


# Global variables
# ----------------
datafile <- "./Data/Demo.json"
all_places <- data.frame() 
subset_places <- data.frame()
dot_color <- "#000000"


# Default init function
# ---------------------
loadData <- function(filepath = "./Data/Demo.json") {	
   
    datafile <<- filepath
   
	# Import JSON
	places_json <- fromJSON(datafile, flatten=TRUE)
	temp_places <- as.data.frame(places_json)
	
	# Rename columns
	colnames(temp_places)[1] <- "Timestamp"
	colnames(temp_places)[2] <- "Latitude"
	colnames(temp_places)[3] <- "Longitude"
	colnames(temp_places)[4] <- "Accuracy"
	colnames(temp_places)[5] <- "Altitude"
	colnames(temp_places)[6] <- "VertAccuracy"
	colnames(temp_places)[7] <- "Velocity"
	colnames(temp_places)[8] <- "Heading"
	
	# Recalculate latitude and longitude
	temp_places$Latitude <- temp_places $Latitude * 0.0000001
	temp_places$Longitude <- temp_places $Longitude * 0.0000001
	temp_places$Timestamp <- as.POSIXct(as.numeric(as.character(temp_places $Timestamp))/1000,origin="1970-01-01", tz="GMT")
	
	# Set global variable
	all_places <<- temp_places
	return(paste("You have loaded", nrow(all_places), "places."))
}



# ========
#   MAPS
# ========

# DrawZurichMap
# -------------
drawZurichGeoMap <- function () {
	drawLocalGeoMap(8.45, 8.65, 47.27, 47.47)
}

# DrawBerneMap
# -------------
drawBerneGeoMap <- function () {
	# drawLocalGeoMap(7.24, 7.29, 46.84, 47.04)
	drawLocalGeoMap(7.2, 7.32, 46.8, 47.1)
}

# DrawSwissMap
# ------------
drawSwissGeoMap <- function () {
	drawLocalGeoMap(6, 10.5, 45.5, 48)
}

# DrawLocalMap
# ------------
drawLocalGeoMap <- function (long1 = 6, long2 = 10.5, lat1 = 45.5, lat2 = 48.0) {
	
	# Assign coordinates
	long = c(long1, long2)
	lat = c(lat1, lat2)
	
	# Load GeoJSON files
	map_lakes = readOGR("./Geo/switzerland-lakes.geo.json", "OGRGeoJSON")
	map_switzerland = readOGR("./Geo/switzerland-canton.geo.json", "OGRGeoJSON")
	
	# Plot maps
	plot(map_switzerland, xlim=long, ylim=lat, fg="white", col="grey", border="black", lwd=1)
	plot(map_lakes, col="#4a4a4a", border=NA, add=TRUE)
}

# DrawEuropeMap
# ------------
drawEuropeGeoMap <- function () {
	map_europe = readOGR("./Geo/europe.geo.json", "OGRGeoJSON")
	plot(map_europe, xlim=c(-10,30), ylim=c(32, 70), fg="white", col="grey", border="black", lwd=1)
}

# DrawWorldMap
# ------------
drawWorldGeoMap <- function () {
	map_world = readOGR("./Geo/world.geo.json", "OGRGeoJSON")
	plot(map_world, fg="white", col="grey", border="black", lwd=1)
}


# ===============
#   DRAW PLACES
# ===============


# Draw all Places
# ---------------
drawAllPlaces <- function(c = "#000000", ch="•") {
	# Draw all places on map
	# Note: Plot Map First
	lines(all_places$Longitude, all_places$Latitude, col=adjustcolor(c, alpha.f = 0.3), lwd=1)
	points(all_places$Longitude, all_places$Latitude, col=c, lwd=3, pch=ch)
	
	# Comment in console
	return(paste("Plotted", nrow(all_places), "places"))
}

# Generic draw subset Places
# --------------------------
drawSubsetPlaces <- function(c = "#000000", ch="•", l=FALSE) {
	# Draw recent places on map
	# Note: Plot Map First
	if(l) { lines(subset_places$Longitude, subset_places $Latitude, col=adjustcolor(c, alpha.f = 0.3), lwd=1) }
	points(subset_places $Longitude, subset_places $Latitude, col=c, lwd=3, pch=ch)

	# Comment in console
	return(paste("Plotted", nrow(subset_places), "places"))
}





# ===============
#   FILTER DATA
# ===============


# Draw recent Places (Specify a number if you like)
# -------------------------------------------------
drawRecentPlaces <- function(n = 10, c = "#000000", ch="•") {
	# Subset for timeframe, get recent places
	subset_places <<- all_places[1:n, ]

	# Draw recent places on map
	drawSubsetPlaces(c, ch, TRUE)

	# Comment in console
	return(paste("Displaying the", nrow(subset_places), "latest points that have been tracked"))
}


# Draw moving Places
# -------------------------------------------------
drawMovingPlaces <- function(c = "#ff0000", ch="•") {
	subset_places <<- all_places[which(all_places$Velocity > 0),]
	drawSubsetPlaces(c, ch)
	
	# Comment in console
	return(paste("Moving points:", nrow(subset_places), " - Not moving points", nrow(all_places)-nrow(subset_places)))
}


# Geographic points of interest
# -----------------------------

drawMostNorthernPoint <- function(c = "#ff0000", ch="•") {
	# Find and draw most northern point
	subset_places <<- all_places[order(all_places$Latitude, decreasing=TRUE)[1],]
	drawSubsetPlaces(c, ch)
	
	# Comment in console
	return(paste("Most northern point at:", subset_places$Latitude[1]))
}

drawMostSouthernPoint <- function(c = "#ff0000", ch="•") {
	# Find and draw most southern point
	subset_places <<- all_places[order(all_places$Latitude, decreasing=FALSE)[1],]
	drawSubsetPlaces(c, ch)
	
	# Comment in console
	return(paste("Most southern point at:", subset_places$Latitude[1]))
}

drawMostEasternPoint <- function(c = "#ff0000", ch="•") {
	# Find and draw most eastern point
	subset_places <<- all_places[order(all_places$Longitude, decreasing=TRUE)[1],]
	drawSubsetPlaces(c, ch)
	
	# Comment in console
	return(paste("Most eastern point at:", subset_places$Longitude[1]))
}

drawMostWesternPoint <- function(c = "#ff0000", ch="•") {
	# Find and draw most western point
	subset_places <<- data.frame()
	subset_places <<- all_places[order(all_places$Longitude, decreasing=FALSE)[1],]
	drawSubsetPlaces(c, ch)
	
	# Comment in console
	return(paste("Most western point at:", subset_places$Longitude[1]))
}

drawHighestPoint <- function(c = "#ff0000", ch="•") {
	# Find and draw most northern point
	subset_places <<- all_places[order(all_places$Altitude, decreasing=TRUE)[1],]
	drawSubsetPlaces(c, ch)
	
	# Comment in console
	return(paste("Highest altitude:", subset_places$Altitude[1]))
}

drawLowestPoint <- function(c = "#ff0000", ch="•") {
	# Find and draw most northern point
	subset_places <<- all_places[order(all_places$Altitude, decreasing=FALSE)[1],]
	drawSubsetPlaces(c, ch)
	
	# Comment in console
	return(paste("Lowest altitude:", subset_places$Altitude[1]))
}

drawHighestVelocity <- function(c = "#ff0000", ch="•") {
	# Find and draw most northern point
	subset_places <<- all_places[order(all_places$Velocity, decreasing=TRUE)[1],]
	drawSubsetPlaces(c, ch)
	
	# Comment in console
	return(paste("Highest velocity:", subset_places$Velocity[1]))
}


# Filter by Time
# --------------
drawWeekendPoints <- function(c = "#00ff00", ch="•") {
	# Find and draw datapoints tracked on weekends using the POSIXlt Timestamp attribute $wday
	subset_places <<- all_places[ (as.POSIXlt(all_places$Timestamp)$wday > 5), ]
	drawSubsetPlaces(c, ch)

	# Comment in console
	return(paste("You have tracked", nrow(subset_places) ,"places on weekends."))
}

drawWorkdayPoints <- function(c = "#0000ff", ch="•") {
	# Find and draw datapoints tracked on weekends using the POSIXlt Timestamp attribute $wday
	subset_places <<- all_places[ (as.POSIXlt(all_places$Timestamp)$wday < 6), ]
	drawSubsetPlaces(c, ch)

	# Comment in console
	return(paste("You have tracked", nrow(subset_places) ,"places on workdays."))
}

drawDaytimePoints <- function(c = "#00ff00", ch="•") {
	# Find and draw datapoints tracked on weekends using the POSIXlt Timestamp attribute $wday
	subset_places <<- all_places[ (as.POSIXlt(all_places$Timestamp)$hour > 7) & (as.POSIXlt(all_places$Timestamp)$hour < 20), ]
	drawSubsetPlaces(c, ch)

	# Comment in console
	return(paste("You have tracked", nrow(subset_places) ,"between 08:00 and 20:00"))
}

drawNighttimePoints <- function(c = "#0000ff", ch="•") {
	# Find and draw datapoints tracked on weekends using the POSIXlt Timestamp attribute $wday
	subset_places <<- all_places[ !((as.POSIXlt(all_places$Timestamp)$hour > 7) & (as.POSIXlt(all_places$Timestamp))$hour < 20), ]
	drawSubsetPlaces(c, ch)

	# Comment in console
	return(paste("You have tracked", nrow(subset_places) ,"places between 20:00 and 08:00"))
}

drawDayPoints <- function(day = "2018-01-27", c = "#000000", ch="•") {
	# Find and draw datapoints tracked on weekends using the POSIXlt Timestamp attribute $wday
	subset_places <<- all_places[ substr(all_places$Timestamp, 1, 10) == day, ]
	drawSubsetPlaces(c, ch, TRUE)

	# Comment in console
	return(paste("You have tracked", nrow(subset_places) ,"places on", day))
}


drawTimerangePoints <- function(startdate = "2018-01-01", enddate = "2018-07-01", c ="#000000", ch="•") {	
	# Parse start- and enddate
	start <- as.POSIXct(startdate)
	end <- paste(enddate, "23:59:59")
	end <- as.POSIXct(end)
	
	# subset_places <<- all_places[ as.numeric(gsub('-','', substr(all_places$Timestamp), 1, 10) >= start & substr(all_places$Timestamp, 1, 10) <= enddate, ]
	subset_places <<- all_places[ as.numeric(all_places$Timestamp) > as.numeric(start) & as.numeric(all_places$Timestamp) <= as.numeric(end), ]
	drawSubsetPlaces(c, ch, TRUE)
	
	# Comment in console
	return(paste("You have tracked", nrow(subset_places) ,"places between", startdate, "and", end))
}


# ================
#   OTHER CHARTS
# ================
drawTimerangeAltitudeChart <- function(startdate = "2018-01-01", enddate = "2018-07-01", c ="#000000") {	
	# Parse start- and enddate
	start <- as.POSIXct(startdate)
	end <- paste(enddate, "23:59:59")
	end <- as.POSIXct(end)
	
	subset_places <<- all_places[ as.numeric(all_places$Timestamp) > as.numeric(start) & as.numeric(all_places$Timestamp) <= as.numeric(end), ]
	drawSubsetPlaces(c, TRUE)
	
	plot.new()
	plot(subset_places$Timestamp, subset_places$Altitude, xlab="Timerange", ylab="Altitude", type="l")
}

# ===========
#   HELPERS
# ===========


# Clear workspace (resets R)
# --------------------------
clear <- function() {
  ENV <- globalenv()
  ll <- ls(envir = ENV)
  ll <- ll[ll != "clr"]
  rm(list = ll, envir = ENV)
}


# Check
# ----
check <- function(x) {
	return("Script loaded, everything ok")
}

