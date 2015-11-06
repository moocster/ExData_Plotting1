## Download data from url, and create red histogram of Global Active Power (kilowatts)
## Output shall be in a 480x480 png file named plot1.png

library(dplyr)

skip_download = FALSE

data_url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
data_file <- "data/household_power_consumption.zip"

dates_to_keep <- c("2/1/2007", "2/2/2007")


if (!dir.exists("data")) {
    stopifnot(dir.create("data", mode="0755"))
}

if (!skip_download){
    stopifnot(download.file(data_url, data_file, method="curl", mode="wb") == 0)
}
date_downloaded <- date()

## The file is a .zip file, and we need to use unz to unpack and open the single file within it

## dt = fread(unz(data_file, "household_power_consumption.txt"), header=TRUE, na.strings=c("?"))
df <- read.csv(unz(data_file, "household_power_consumption.txt"),
              header=TRUE, sep=";", na.strings=c("?"))

## Before converting dates and times, subset to retain only rows that we're interested in
##df <- df[df$Date %in% dates_to_keep,]    # Results in 2880 obs. of 9 variables
df <- filter(df, Date %in% dates_to_keep)

ok <- complete.cases(df)                 # Turns out all are complete
df <- df[ok, ]


png("plot1.png", width=480, height=480)

hist(df$Global_active_power, col="red",
     xlab="Global Active Power (kilowatts)", main="Global Active Power")

dev.off()
