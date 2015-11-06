### Download data from url, and plot Energy sub metering vs date,
### with x-axis ticks at "Thu", "Fri", "Sat"
### Output shall be a 480x480 png file named plot3.png

library(dplyr)

skip_download = FALSE

data_url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
data_file <- "data/household_power_consumption.zip"

dates_to_keep <- c("1/2/2007", "2/2/2007") # DD/MM/YY  not typical US order!


if (!dir.exists("data")) {
    stopifnot(dir.create("data", mode="0755"))
}

if (!skip_download){
    stopifnot(download.file(data_url, data_file, method="curl", mode="wb") == 0)
}
date_downloaded <- date()

## The file is a .zip file, and we need to use unz to unpack and open the single file within it
df <- read.csv(unz(data_file, "household_power_consumption.txt"),
              header=TRUE, sep=";", na.strings=c("?"), stringsAsFactors=FALSE)


## Before converting dates and times, subset to retain only rows that we're interested in
## df <- df[df$Date %in% dates_to_keep,]    # Results in 2880 obs. of 9 variables
df <- filter(df, Date %in% dates_to_keep)

ok <- complete.cases(df)                 # Turns out all are complete
df <- df[ok, ]


convert_dt <- function(date, time) {
    ## Convert date and time as found in data file into POSIXct
    ##
    ## Args:
    ##   date: character vector in DD/MM/YYYY format (or vector of same)
    ##   time: character vector in HH:MM:SS format (or vector of same)
    ##
    ## Returns:
    ##   POSIXct object (or vector of same if date and time are vectors)
    ##
    ## Note:
    ##   Given that actual timezone of data is unknown, assume UTC
    ##
    as.POSIXct(strptime(paste(date, time), "%d/%m/%Y %H:%M:%S", tz="GMT"))
}

## Convert Date and Time strings to POSIXct
##df$When <- convert_dt(df$Date, df$Time)
df <- mutate(df, When=convert_dt(Date, Time))


png("plot3.png", width=480, height=480)

ylab_text <- "Energy sub metering"                             # Exactly match example
#ylab_text <- "Active Energy Consumed per Minute (Watt-hour)" # A better label

## plot labels, sub_metering_1
plot(df$When, df$Sub_metering_1, type="l",
     xlab="", ylab=ylab_text)

lines(df$When, df$Sub_metering_2, col="red")
lines(df$When, df$Sub_metering_3, col="blue")

legend("topright", lty=1,
       col=c("black", "red", "blue"),
       legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))


dev.off()
