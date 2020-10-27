library(googledrive)
library(dplyr)
library(readr)

# Google Docs interaction fucntions ############################################


gd_download <- function(file, ext = "csv"){
  tmp_path <- fs::file_temp(ext = ext)
  drive_download(file = file, path = tmp_path)
  doc <- read_csv(tmp_path, col_types = "c")
  fs::file_delete(tmp_path)
  doc
}

gd_put <- function(media, name, path, type = "spreadsheet", ext = "csv"){
  tmp_path <- fs::file_temp(ext = ext)
  write_csv(x = media, file = tmp_path)
  drive_put(media = tmp_path, path = path, name = name, type = type)
  fs::file_delete(tmp_path)
}
