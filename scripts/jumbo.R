# Precios de Supermercados

# ---- Paquetes ----
library(tidyverse)
library(rvest)
library(polite)
library(lubridate)
library(XML)
library(httr)
library(xml2)

setwd("~/GitHub/DIE_Supermercados")
source('super_funciones.R')
user_agent <- "Juan Quinonez - juansqw@gmail.com"

# ---- Jumbo ----
# 1. Lista de links de categorias de productos
categorias <- bow(url = "https://jumbo.com.do/",
                  user_agent = user_agent,
                  delay = 1) %>% 
  scrape() %>% 
  html_elements('.level2') %>% 
  html_elements('a') %>% 
  html_attr('href') %>% 
  paste0(.,"?product_list_limit=all")

# 2. Extrae informacion de articulos

# Divide la cantidad de categorias en grupos para realizar la extraccion
# de informacion. 

start <- seq(1, length(categorias), by = 10)
end <- start + 9
today_list <- vector(mode = "list", length = length(start))

iter_start <- map_lgl(today_list, ~!is.null(.x)) %>% sum(1) 
iter_end <- length(today_list)

for (i in seq(iter_start, iter_end)) {
  
  today_list[[i]] <- map(
    categorias[seq(start[i], end[i])],
    jumbo_articles)
  
  print(paste0(i, " - ", iter_end," / ", Sys.time()))
  Sys.sleep(runif(1,3,5))
}

are_df <- map(today_list, ~.x %>% map_lgl(is.data.frame))

today_list <- map2(today_list, are_df, ~.x[.y])

today <- today_list %>% 
  map(bind_rows) %>%
  bind_rows() %>% 
  mutate(Store = c("Jumbo"),
         Date = Sys.Date())

# 3. Actualiza informacion historica
saveRDS(today, "today_Jumbo.RDS")
print('Saved Jumbo')
