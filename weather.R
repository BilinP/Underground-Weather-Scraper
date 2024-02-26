#library needed for project
library(RSelenium)
library(rvest)
library(netstat)

#list of urls below
urls<-list("https://www.wunderground.com/history/daily/us/ca/burbank/KBUR/date/", "https://www.wunderground.com/history/daily/us/ca/reseda/KBUR/date/")
weatherData<-read.csv(file.path("Template","weatherData.csv"))

#function which takes a startdate and enddate and then create a table with data. 
#make sure the input for each day is in the form of year-month-day ex. "2024-2-23"
#example call weather_data("2024-2-20","2024-2-23")
weather_data<-function(startdate,enddate){
  

#start RSelenium browser
remote<-rsDriver(browser = "chrome",chromever="122.0.6261.69",verbose = FALSE,port=free_port())
remDr <- remote[["client"]]


#create a list thorugh the sequence days starting from startdate to enddate.
dates <- seq(as.Date(startdate), as.Date(enddate), by=1)

#url iteration
for(u in urls){
  #date iteration
  for(i in seq_along(dates)){
   
    #create the full url with concatenation of the url and date
    url = paste0(u, dates[i])
    # opens the link from the browser 
    remDr$navigate(url)
    
    #gets/read the html content of the page
    html<-remDr$getPageSource()[[1]]
    htmlread<-read_html(html)  
    
    #gets the table portion of the data
    tables<-html_table(htmlread)[[1]]
    
    #clean data
    clean_data <- tables[-c(15,12,7,1,5,17:22),-c(1,3:5) ] #remove rows: 15,12,7,1,5,17-22, column: 1 , 3-5
    flip<-t(clean_data) #transpose the data from rows to column and column to rows.
    
    
    parts <- unlist(strsplit(url, "/"))# split the url by each "/" character
    location <- parts[8] #uses the 8th part which holds the location
    date <- c(dates[i]) # uses the current date its on
    
    # Create a new table with the new columns, date and location.
    new_data <- data.frame(date, location, flip)
    
    # combine the old data with the new data. 
    final <- rbind(as.matrix(weatherData), as.matrix(new_data))
    
    # Convert the result back.
    weatherData <- as.data.frame(final)
    
    #writes/update csv for each iteration of url and data thus making it save it's progress.
    write.csv(weatherData, "weatherData.csv", append = TRUE, row.names = FALSE)
  }
}
#stops the Selenium and closes the window 
remDr$close()
remDr$server$stop()

#return the weatherData as table
return(weatherData)
}
