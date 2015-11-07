### Download data from url and create a 2x2 panel of plots.
### Output shall be a 480x480 png file named plot4.png

library(dplyr)

skip_download = TRUE

data_url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
data_file <- "data/household_power_consumption.zip"

dates_to_keep <- c("1/2/2007", "2/2/2007") # DD/MM/YY  N.B. Euro, not US order.

## ------------------------------------------------------------------------
##     Download the data, read it in, subset, date/time conversions
## ------------------------------------------------------------------------

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

## Convert Date and Time strings to POSIXct
##df$When <- convert_dt(df$Date, df$Time)
df <- mutate(df, When=convert_dt(Date, Time))

## ------------------------------------------------------------------------
##                          Create the plots
## ------------------------------------------------------------------------

plot_global_active_power <- function() {
    plot(df$When, df$Global_active_power, type="l",
         xlab="", ylab="Global Active Power")
}

plot_global_reactive_power <- function() {
    plot(df$When, df$Global_reactive_power, type="l",
         xlab="datetime", ylab="Global Reactive Power")
}

plot_voltage <- function() {
    plot(df$When, df$Voltage, type="l", xlab="datetime", ylab="Voltage")
}

plot_energy_sub <- function() {
    ylab_text <- "Energy sub metering"                              # Exactly match example
    ##ylab_text <- "Active Energy Consumed per Minute (Watt-hour)" # A better label

    ## plot labels, sub_metering_1
    plot(df$When, df$Sub_metering_1, type="l",
         xlab="", ylab=ylab_text)

    lines(df$When, df$Sub_metering_2, col="red")
    lines(df$When, df$Sub_metering_3, col="blue")

    legend("topright", lty=1,
           col=c("black", "red", "blue"),
           legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
}



png("plot4.png", width=480, height=480)

try({
    old_par <- par(no.readonly=TRUE)

    par(mfrow = c(2, 2), mar = c(7, 4, 3, 2))

    plot_global_active_power()
    plot_voltage()
    plot_energy_sub()
    plot_global_reactive_power()
})
par(old_par)

dev.off()
