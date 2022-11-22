# Consolida precios de supermercados

# ---- Paquetes ----
library(tidyverse)
library(lubridate)
library(xts)

# ---- Data ----
setwd("~/GitHub/DIE_Supermercados")

files <- list.files(path = getwd(), 
                    pattern = ".RDS",
                    full.names = TRUE, 
                    recursive = FALSE)  

# DATAFRAME OF FILE, DIR, AND METADATA
filesdf <- cbind(file=files,
                 dir=dirname(files),
                 data.frame(file.info(files), row.names =NULL),
                 stringsAsFactors=FALSE) |> 
  filter(mtime >= Sys.Date() - 2)

today <- dir(filesdf$file) %>%
  map_dfr(.,readRDS)

saveRDS(today, paste0(Sys.Date(),".RDS"))

# 
# # ---- Funciones ----
# fill_locf <- function(store, articulo, i){
#   temp_db <- data %>%
#     filter(Articulos == articulo,
#            Store == store)
#   
#   ind <- data.frame(Date = seq(from = min(temp_db$Date),
#                                to = max(temp_db$Date),
#                                by = 'days'))
#   
#   check <- left_join(x = ind,
#                      y = temp_db,
#                      by = c('Date' = 'Date')) %>%
#     na.locf()
#   
#   print(paste0(i, ' - ',nrow(ind)))
#   return(check)
# }
# 
# # ---- Data ----
# setwd("~/GitHub/DIE_Supermercados")
# dbSupermercados  <- readRDS("dbSupermercados.RDS")
# 
# gc() 
# 
# last_obs <- dbSupermercados %>% 
#   select(-Precio) %>% 
#   group_by(Articulos, Store) %>% 
#   summarise(Date = max(Date, na.rm = TRUE)) %>% 
#   ungroup() %>% 
#   left_join(x = .,
#             y = dbSupermercados,
#             by = c('Articulos' = 'Articulos',
#                    'Store' = 'Store',
#                    'Date' = 'Date'))
# 
# today <- dir(pattern = glob2rx("today*.RDS")) %>%
#   map_dfr(.,readRDS)
# 
# data <- bind_rows(last_obs, today) %>% 
#   filter(Articulos != '') %>% 
#   unique()
#   
# art_list <- data %>%
#   select(Store, Articulos) %>%
#   group_by(Store, Articulos) %>% 
#   summarise(cnt = n()) %>% 
#   ungroup()
# 
# art_list2 <- left_join(x = art_list,
#                        y = data) %>% 
#   mutate(keep = case_when(cnt >= 2 ~ 1,
#                           cnt == 1 & Date == max(data$Date, na.rm = TRUE) ~ 1)) %>% 
#   na.omit() %>% 
#   select(Store, Articulos) %>%   
#   unique() %>% 
#   mutate(i = row_number())
# 
# colnames(art_list2) <- c('store', 'articulo','i')
# gc()
# 
# today_complete <- pmap_dfr(art_list2, fill_locf)
# 
# check <- anti_join(today_complete,
#                    dbSupermercados) %>% 
#   unique()
# 
# dbSupermercados <- bind_rows(dbSupermercados,
#                               check)
# 
# saveRDS(dbSupermercados, "dbSupermercados.RDS")
# 
# gc()
# 
# # ---- Resumen ----
# db3 <- dbSupermercados %>%
#   filter(Date >= Sys.Date()-30) %>% 
#   mutate(i = row_number()) %>% 
#   pivot_wider(names_from = Store,
#               values_from = Precio) %>% 
#   dplyr::select(-Articulos) %>% 
#   group_by(Date) %>% 
#   summarize(La_Sirena = mean(LaSirena, na.rm = TRUE),
#             El_Nacional = mean(ElNacional, na.rm = TRUE),
#             Pricesmart = mean(Pricesmart, na.rm = TRUE),
#             Plaza_Lama = mean(PlazaLama, na.rm = TRUE),
#             #Bravo = mean(Bravo, na.rm = TRUE),
#             #Carrefour = mean(Carrefour, na.rm = TRUE),
#             #PedidosYa = mean(PedidosYa, na.rm = TRUE),
#             Jumbo = mean(Jumbo, na.rm = TRUE),
#             Los_Hidalgos = mean(LosHidalgos, na.rm = TRUE)) %>% 
#   arrange(desc(Date))
# 
# write_csv(db3,"db3.csv")
