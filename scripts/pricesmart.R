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

# ---- Pricesmart ----
categorias <- bow(url = "https://www.pricesmart.com/site/do/es",
                  user_agent = user_agent,
                  delay = 0.1) %>% 
  scrape() %>%
  html_nodes('.categories-section-link') %>% 
  html_attr('href') %>% 
  paste0("https://www.pricesmart.com",.)

Sys.sleep(runif(1,3,5))

# Subcategorias
subcategorias <- map(categorias, pricesmart_subcategorias) %>% 
  unlist()

Sys.sleep(runif(1,5,10))

# Pages
pages_per_sub <- map(subcategorias, pricesmart_pages) %>% 
  unlist()

pgs_pricesmart <- map2(subcategorias, pages_per_sub, pricesmart_url_pgs) %>% 
  unlist()

Sys.sleep(runif(1,5,10))

# 2. Extrae informacion de articulos
# Divide la cantidad de categorias en grupos para realizar la extraccion
# de informacion.

start <- seq(1, length(pgs_pricesmart), by = 5)
end <- start + 4
today_list <- vector(mode = "list", length = length(start))

iter_start <- map_lgl(today_list, ~!is.null(.x)) %>% sum(1) 
iter_end <- length(today_list)

for (i in seq(iter_start, iter_end)) {
  
  today_list[[i]] <- map(
    pgs_pricesmart[seq(start[i], end[i])],
    pricesmart_articles)
  
  print(paste0(i, " - ", iter_end," / ", Sys.time()))
  Sys.sleep(runif(1,5,10))
}

are_df <- map(today_list, ~.x %>% map_lgl(is.data.frame))

today_list <- map2(today_list, are_df, ~.x[.y])

today <- today_list %>% 
  map(bind_rows) %>%
  bind_rows() %>% 
  mutate(Store = c("Pricesmart"),
         Date = Sys.Date())

# 3. Actualiza informacion historica
saveRDS(today, 'today_Pricesmart.RDS')
print('Saved Pricesmart')
