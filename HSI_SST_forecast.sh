#!/bin/bash

#folder for datasets download and other variables
download_dir=/usr/src/app/data/download/tem
aoi=/usr/src/app/data/EEZ_RO_BG_3857_fixed.shp


#denumiri si indicative produse
service_id=BLKSEA_ANALYSISFORECAST_PHY_007_001-TDS
product_id=bs-cmcc-tem-an-fc-d
#sv03-bs-cmcc-tem-an-fc-d

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

python3 -m motuclient --user 'sasrc' --pwd 'Skyf1sh#1' --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id $service_id --product-id $product_id --longitude-min 27.3701 --longitude-max 33.9625 --latitude-min 40.8601 --latitude-max 46.8500 --date-min $day_2 --date-max $day9 --depth-min 2.5 --depth-max 2.5012 --variable thetao --out-dir $download_dir --out-name sv03_bs_cmcc_tem_an_fc_d_$name_day_2.nc
# it is saved with the time stamp of minus 2 days, since this is the analysis product that is going to be kept

####Procesare####
#extrage tiffuri din NETCDF
lista=("$name_day_2" "$name_day_1" "$name_day0" "$name_day1" "$name_day2" "$name_day3" "$name_day4" "$name_day5" "$name_day6" "$name_day7" "$name_day8" "$name_day9") # creates the list of names to be used for the tif files (indexed starting with 0, therefore $i-1 is required
for i in {1..12}
do
gdal_translate -b $i -a_srs EPSG:4326 -projwin 27.4427 45.215 31.415 41.975 NETCDF:$download_dir/sv03_bs_cmcc_tem_an_fc_d_$name_day_2.nc:thetao $download_dir/sv03_bs_cmcc_temS_an_fc_d_${lista[$i-1]}.tif 
done

#crop to AOI, second resampling, compress and add tiles
for file in `ls $download_dir/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
gdalwarp -overwrite -t_srs EPSG:3857 -dstnodata -32768 -ot Float32  -tr 1000 1000 -r bilinear -co "COMPRESS=DEFLATE" -co "TILED=YES" -cutline $aoi -crop_to_cutline $download_dir/$file $download_dir/crop/$file
done

#Classes of SST and values of SI
class="<-32767, <=1, <=1.1, <=1.2, <=1.3, <=1.4, <=1.5, <=1.6, <=1.7, <=1.8, <=1.9, <=2, <=2.1, <=2.2, <=2.3, <=2.4, <=2.5, <=2.6, <=2.7, <=2.8, <=2.9, <=3, <=3.1, <=3.2, <=3.3, <=3.4, <=3.5, <=3.6, <=3.7, <=3.8, <=3.9, <=4, <=4.1, <=4.2, <=4.3, <=4.4, <=4.5, <=4.6, <=4.7, <=4.8, <=4.9, <=5, <=16, <=16.1, <=16.2, <=16.3, <=16.4, <=16.5, <=16.6, <=16.7, <=16.8, <=16.9, <=17, <=17.1, <=17.2, <=17.3, <=17.4, <=17.5, <=17.6, <=17.7, <=17.8, <=17.9, <=18, <=18.1, <=18.2, <=18.3, <=18.4, <=18.5, <=18.6, <=18.7, <=18.8, <=18.9, <=19, <=19.1, <=19.2, <=19.3, <=19.4, <=19.5, <=19.6, <=19.7, <=19.8, <=19.9, <=20, <=20.1, <=20.2, <=20.3, <=20.4, <=20.5, <=20.6, <=20.7, <=20.8, <=20.9, <=21, <=21.1, <=21.2, <=21.3, <=21.4, <=21.5, <=21.6, <=21.7, <=21.8, <=21.9, <=22, <=45"
val="0, 0.01, 0.03475, 0.0595, 0.08425, 0.109, 0.13375, 0.1585, 0.18325, 0.208, 0.23275, 0.2575, 0.28225, 0.307, 0.33175, 0.3565, 0.38125, 0.406, 0.43075, 0.4555, 0.48025, 0.505, 0.52975, 0.5545, 0.57925, 0.604, 0.62875, 0.6535, 0.67825, 0.703, 0.72775, 0.7525, 0.77725, 0.802, 0.82675, 0.8515, 0.87625, 0.901, 0.92575, 0.9505, 0.97525, 1, 1, 0.9835, 0.967, 0.9505, 0.934, 0.9175, 0.901, 0.8845, 0.868, 0.8515, 0.835, 0.8185, 0.802, 0.7855, 0.769, 0.7525, 0.736, 0.7195, 0.703, 0.6865, 0.67, 0.6535, 0.637, 0.6205, 0.604, 0.5875, 0.571, 0.5545, 0.538, 0.5215, 0.505, 0.4885, 0.472, 0.4555, 0.439, 0.4225, 0.406, 0.3895, 0.373, 0.3565, 0.34, 0.3235, 0.307, 0.2905, 0.274, 0.2575, 0.241, 0.2245, 0.208, 0.1915, 0.175, 0.1585, 0.142, 0.1255, 0.109, 0.0925, 0.076, 0.0595, 0.043, 0.0265, 0.01, 0.01"

#reclass according to class and val
for file in `ls $download_dir/crop/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
python3 /usr/src/app/gdal_reclassify.py $download_dir/crop/$file $download_dir/SI/${file%.tif}_SI.tif -c "$class" -r "$val" -d 0 -n true -p "COMPRESS=DEFLATE"
done



