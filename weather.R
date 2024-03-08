#library needed for project
library(RSelenium)
library(rvest)
library(netstat)


urls<-list("https://www.wunderground.com/history/daily/us/ca/sutter-creek/KJAQ/date/")


#function which takes a startdate and enddate and then create a table with data. 
#make sure the input for each day is in the form of year-month-day ex. "2024-2-23"
#example call weather_data("2024-2-20","2024-2-23")
weather_data<-function(startdate,enddate){
  #start RSelenium browser
  remote<-rsDriver(browser = "firefox",verbose = FALSE,port=free_port(),geckover="latest")
  remDr<-remote[["client"]]
  
  #create a list thorugh the sequence days starting from startdate to enddate.
  dates <- seq(as.Date(startdate), as.Date(enddate), by=1)
  
  #url iteration
  for(u in urls){
    weatherData<<-read.csv(file.path("Template","weatherData.csv")) 
    
    # split the url by each "/" character and uses 8th part which holds location
    location <- unlist(strsplit(u, "/"))[8] 
    # https://www.wunderground.com/history/daily/us/ca/van-nuys/KBUR/2024-2-20
    
    #date iteration
    for(d in seq_along(dates)){
      
      #create the full url with the concatenation of the url and date
      url = paste0(u, dates[d])
      # opens the link from the browser 
      remDr$navigate(url)
      Sys.sleep(1)
      
      #gets/read the html content of the page
      html<-remDr$getPageSource()[[1]]
      tryCatch({
        htmlread<-read_html(html)
        date<- as.character(dates[d])
        #gets the table portion of the data
        tables<-html_table(htmlread)[[1]]
        
        #clean data
        #remove rows: 15,12,7,1,5,17-22, column: 1 , 3-5
        clean_data <- tables[-c(15,12,7,1,5,17:22),-c(1,3:5) ] 
        flip<-t(clean_data) #transpose the data from rows to column and column to rows.
        
        # Create a new data frame with the new columns data, date and location.
        new_data <- data.frame(date, location, flip)
        # Makes new_data have the same column names: for rbind()
        colnames(new_data) <- colnames(weatherData) 
        weatherData <<- rbind(weatherData,new_data)  # combine the old data with the new data. 
        
        #writes/update csv for each iteration aof url and data thus making it save it's progress.
        write.csv(weatherData, paste0(location, ".csv"),row.names = FALSE)
      }, error= function(e){ # Called if any error parsing through webpage.
        # fills row with date,location,and rest NA
        new_data <- data.frame(date, location, matrix(NA, ncol = 11))
        colnames(new_data) <- colnames(weatherData) 
        # combine the old data with error(NA) row
        weatherData <<- rbind(weatherData,new_data)
        write.csv(weatherData, paste0(location, ".csv"), row.names = FALSE)
      })
    }
  }
  #stops the Selenium and closes the window 
  remDr$closeWindow()
  remote$server$stop()
  #return the weatherData as table
  return(weatherData)
}
