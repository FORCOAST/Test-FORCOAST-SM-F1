#!/bin/bash

#(C) Copyright FORCOAST H2020 project under Grant No. 870465. All rights reserved.

# Copyright notice
# --------------------------------------------------------------------
#  Copyright 2022 Terrasigna
#   Ionut Serban
#
#   ionut.serban@terrasigna.com
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#
#        http://www.apache.org/licenses/LICENSE-2.0
# --------------------------------------------------------------------

#folder for datasets download and other variables
download_dir=/usr/src/app/data/download/sal
aoi=/usr/src/app/data/EEZ_RO_BG_3857_fixed.shp


#denumiri si indicative produse
service_id=BLKSEA_ANALYSISFORECAST_PHY_007_001-TDS
product_id=bs-cmcc-sal-an-fc-d

#sv03-bs-cmcc-sal-an-fc-d

#time variables for download period; should have the following format: YYYY-mm-dd ("2018-06-26")
day_2=$(date -d "-2 days" +%Y-%m-%d) #minus 2 day - the one that reaches analysis product
day9=$(date -d "+9 days" +%Y-%m-%d)

#define name for each tif renaming
name_day_2=$(date -d "-2 days" +%Y%m%d)
name_day_1=$(date -d "-1 days" +%Y%m%d)
name_day0=$(date +%Y%m%d)
name_day1=$(date -d "+1 days" +%Y%m%d)
name_day2=$(date -d "+2 days" +%Y%m%d)
name_day3=$(date -d "+3 days" +%Y%m%d)
name_day4=$(date -d "+4 days" +%Y%m%d)
name_day5=$(date -d "+5 days" +%Y%m%d)
name_day6=$(date -d "+6 days" +%Y%m%d)
name_day7=$(date -d "+7 days" +%Y%m%d)
name_day8=$(date -d "+8 days" +%Y%m%d)
name_day9=$(date -d "+9 days" +%Y%m%d)

python3 -m motuclient --user 'sasrc' --pwd 'Skyf1sh#1' --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id $service_id --product-id $product_id --longitude-min 27.3701 --longitude-max 33.9625 --latitude-min 40.8601 --latitude-max 46.8500 --date-min $day_2 --date-max $day9 --depth-min 2.5 --depth-max 2.5012 --variable so --out-dir $download_dir --out-name sv03_bs_cmcc_sal_an_fc_d_$name_day_2.nc
# it is saved with the time stamp of minus 2 days, since this is the analysis product that is going to be kept

####Procesare####
#extrage tiffuri din NETCDF
lista=("$name_day_2" "$name_day_1" "$name_day0" "$name_day1" "$name_day2" "$name_day3" "$name_day4" "$name_day5" "$name_day6" "$name_day7" "$name_day8" "$name_day9") # creates the list of names to be used for the tif files (indexed starting with 0, therefore $i-1 is required
for i in {1..12}
do
gdal_translate -b $i -a_srs EPSG:4326 -projwin 27.4427 46.8495 32.4365 41.9 $download_dir/sv03_bs_cmcc_sal_an_fc_d_$name_day_2.nc $download_dir/sv03_bs_cmcc_sal_an_fc_d_${lista[$i-1]}.tif 
done

#crop to AOI, second resampling, compress and add tiles
for file in `ls $download_dir/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
gdalwarp -overwrite -t_srs EPSG:3857 -dstnodata -32768 -ot Float32  -tr 1000 1000 -r bilinear -co "COMPRESS=DEFLATE" -co "TILED=YES" -cutline $aoi -crop_to_cutline $download_dir/$file $download_dir/crop/$file
done

#Classes of SST and values of SI
class="<-32767, <=8, <=8.1, <=8.2, <=8.3, <=8.4, <=8.5, <=8.6, <=8.7, <=8.8, <=8.9, <=9, <=9.1, <=9.2, <=9.3, <=9.4, <=9.5, <=9.6, <=9.7, <=9.8, <=9.9, <=10, <=10.1, <=10.2, <=10.3, <=10.4, <=10.5, <=10.6, <=10.7, <=10.8, <=10.9, <=11, <=11.1, <=11.2, <=11.3, <=11.4, <=11.5, <=11.6, <=11.7, <=11.8, <=11.9, <=12, <=12.1, <=12.2, <=12.3, <=12.4, <=12.5, <=12.6, <=12.7, <=12.8, <=12.9, <=13, <=13.1, <=13.2, <=13.3, <=13.4, <=13.5, <=13.6, <=13.7, <=13.8, <=13.9, <=14, <=14.1, <=14.2, <=14.3, <=14.4, <=14.5, <=14.6, <=14.7, <=14.8, <=14.9, <=15, <=40"
val="0, 0.01, 0.0241428571, 0.0382857143, 0.0524285714, 0.0665714286, 0.0807142857, 0.0948571429, 0.109, 0.1231428571, 0.1372857143, 0.1514285714, 0.1655714286, 0.1797142857, 0.1938571429, 0.208, 0.2221428571, 0.2362857143, 0.2504285714, 0.2645714286, 0.2787142857, 0.2928571429, 0.307, 0.3211428571, 0.3352857143, 0.3494285714, 0.3635714286, 0.3777142857, 0.3918571429, 0.406, 0.4201428571, 0.4342857143, 0.4484285714, 0.4625714286, 0.4767142857, 0.4908571429, 0.505, 0.5191428571, 0.5332857143, 0.5474285714, 0.5615714286, 0.5757142857, 0.5898571429, 0.604, 0.6181428571, 0.6322857143, 0.6464285714, 0.6605714286, 0.6747142857, 0.6888571429, 0.703, 0.7171428571, 0.7312857143, 0.7454285714, 0.7595714286, 0.7737142857, 0.7878571429, 0.802, 0.8161428571, 0.8302857143, 0.8444285714, 0.8585714286, 0.8727142857, 0.8868571429, 0.901, 0.9151428571, 0.9292857143, 0.9434285714, 0.9575714286, 0.9717142857, 0.9858571429, 1, 1"

#reclass according to class and val
for file in `ls $download_dir/crop/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
python3 /usr/src/app/lib/gdal_reclassify.py $download_dir/crop/$file $download_dir/SI/${file%.tif}_SI.tif -c "$class" -r "$val" -d 0 -n true -p "COMPRESS=DEFLATE"
done





