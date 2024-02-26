
# Underground Weather Scraper

This Web Scrapper will scrape data from Weather Underground (https://www.wunderground.com/) using RSelenium and Rvest. Its goal is to scrape the following data from different weather stations around California for each day. The following data collected are temperature, perception, dew point, wind speed, visibility, and sea level pressure. 


## Installation

To use code install a R compiler and the following packages in R: RSelenium, rvest, netstat.

```R
install.packages(c("rvest", "netstat","RSelenium"))
```
In the code, please change the remDr to match a browser of your choice and its version. A good resource to figure this out is the following link: https://www.youtube.com/watch?v=GnpJujF9dBw
    
## Usage/Examples

```R
weather_data("2024-2-20","2024-2-23")
```


## Author

- [@BilinP](https://www.github.com/BilinP)


## Acknowledgements

 - [RSelenium Installation](https://www.youtube.com/watch?v=GnpJujF9dBw)
 - [RSelenium + Rvest Usages](https://www.youtube.com/watch?v=Dkm1d4uMp34)


## License

[MIT](https://choosealicense.com/licenses/mit/)

