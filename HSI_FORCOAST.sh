########################################################################
#input data info
#sea surface salinity and sea surface temperature available at CMEMS
#product BLKSEA_MULTIYEAR_PHY_007_004: https://resources.marine.copernicus.eu/product-detail/BLKSEA_MULTIYEAR_PHY_007_004/INFORMATION
#salinity: bs-cmcc-sal-rean-d
#temperature: bs-cmcc-tem-rean-d
#we also used as input the Black Sea bathymetry available at EMODTNET

########################################################################
#processing data from CMEMS
#input *.nc file (one with SST and one with SSS, each band represents a daily product (salinity or sst)

#process salinity data
#exctract daily producs form *.nc
mkdir sal
d=2017-01-01
for i in {1..1095}
do
echo $d
output_name="SSS_$d.tif"
echo $output_name
gdal_translate -b $i -a_srs EPSG:4326 -projwin 27.4427 46.8495 33.9625 40.8601 bs-cmcc-sal-rean-d_2017_2019.nc sal/$output_name
d=$(date -I -d "$d + 1 day")
done

#process temperature data
#exctract daily producs form *.nc
mkdir tem
d=2017-01-01
for i in {1..1095}
do
echo $d
output_name="SST_$d.tif"
echo $output_name
gdal_translate -b $i -a_srs EPSG:4326 -projwin 27.4427 46.8495 33.9625 40.8601 bs-cmcc-tem-rean-d_2017_2019.nc tem/$output_name
d=$(date -I -d "$d + 1 day")
done

#crop to AOI, second resampling, compress and add tiles
#run this part fot both salinity and tempperature
#set the working dir
download_dir/=/path/to/previously/extracted/tifs/
#set the shapefile
aoi=/path/to/aoi/dir/EEZ_RO_BG_3857_fixed.shp
#create a new dir for croped tifs
mkdir $download_dir/crop
for file in `ls $download_dir/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
gdalwarp -overwrite -t_srs EPSG:3857 -dstnodata -32768 -ot Float32  -tr 1000 1000 -r bilinear -co "COMPRESS=DEFLATE" -co "TILED=YES" -cutline $aoi -crop_to_cutline $download_dir/$file $download_dir/crop/$file
done

#reclass according to class and val - creating an SI for salinity (SSS) and temperature (SST)
#gdal_reclassify.py is a separate script that uses class and val as inputs

#define classes for SST
class="<-32767, <=1, <=1.1, <=1.2, <=1.3, <=1.4, <=1.5, <=1.6, <=1.7, <=1.8, <=1.9, <=2, <=2.1, <=2.2, <=2.3, <=2.4, <=2.5, <=2.6, <=2.7, <=2.8, <=2.9, <=3, <=3.1, <=3.2, <=3.3, <=3.4, <=3.5, <=3.6, <=3.7, <=3.8, <=3.9, <=4, <=4.1, <=4.2, <=4.3, <=4.4, <=4.5, <=4.6, <=4.7, <=4.8, <=4.9, <=5, <=16, <=16.1, <=16.2, <=16.3, <=16.4, <=16.5, <=16.6, <=16.7, <=16.8, <=16.9, <=17, <=17.1, <=17.2, <=17.3, <=17.4, <=17.5, <=17.6, <=17.7, <=17.8, <=17.9, <=18, <=18.1, <=18.2, <=18.3, <=18.4, <=18.5, <=18.6, <=18.7, <=18.8, <=18.9, <=19, <=19.1, <=19.2, <=19.3, <=19.4, <=19.5, <=19.6, <=19.7, <=19.8, <=19.9, <=20, <=20.1, <=20.2, <=20.3, <=20.4, <=20.5, <=20.6, <=20.7, <=20.8, <=20.9, <=21, <=21.1, <=21.2, <=21.3, <=21.4, <=21.5, <=21.6, <=21.7, <=21.8, <=21.9, <=22, <=45"
val="0, 0.01, 0.03475, 0.0595, 0.08425, 0.109, 0.13375, 0.1585, 0.18325, 0.208, 0.23275, 0.2575, 0.28225, 0.307, 0.33175, 0.3565, 0.38125, 0.406, 0.43075, 0.4555, 0.48025, 0.505, 0.52975, 0.5545, 0.57925, 0.604, 0.62875, 0.6535, 0.67825, 0.703, 0.72775, 0.7525, 0.77725, 0.802, 0.82675, 0.8515, 0.87625, 0.901, 0.92575, 0.9505, 0.97525, 1, 1, 0.9835, 0.967, 0.9505, 0.934, 0.9175, 0.901, 0.8845, 0.868, 0.8515, 0.835, 0.8185, 0.802, 0.7855, 0.769, 0.7525, 0.736, 0.7195, 0.703, 0.6865, 0.67, 0.6535, 0.637, 0.6205, 0.604, 0.5875, 0.571, 0.5545, 0.538, 0.5215, 0.505, 0.4885, 0.472, 0.4555, 0.439, 0.4225, 0.406, 0.3895, 0.373, 0.3565, 0.34, 0.3235, 0.307, 0.2905, 0.274, 0.2575, 0.241, 0.2245, 0.208, 0.1915, 0.175, 0.1585, 0.142, 0.1255, 0.109, 0.0925, 0.076, 0.0595, 0.043, 0.0265, 0.01, 0.01"

for file in `ls $download_dir/crop/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
python /path/to/gdal_reclassify.py $download_dir/crop/$file $download_dir/SI/${file%.tif}_SI.tif -c "$class" -r "$val" -d 0 -n true -p "COMPRESS=DEFLATE"
done

#Classes of SSS  and values of SI
class="<-32767, <=8, <=8.1, <=8.2, <=8.3, <=8.4, <=8.5, <=8.6, <=8.7, <=8.8, <=8.9, <=9, <=9.1, <=9.2, <=9.3, <=9.4, <=9.5, <=9.6, <=9.7, <=9.8, <=9.9, <=10, <=10.1, <=10.2, <=10.3, <=10.4, <=10.5, <=10.6, <=10.7, <=10.8, <=10.9, <=11, <=11.1, <=11.2, <=11.3, <=11.4, <=11.5, <=11.6, <=11.7, <=11.8, <=11.9, <=12, <=12.1, <=12.2, <=12.3, <=12.4, <=12.5, <=12.6, <=12.7, <=12.8, <=12.9, <=13, <=13.1, <=13.2, <=13.3, <=13.4, <=13.5, <=13.6, <=13.7, <=13.8, <=13.9, <=14, <=14.1, <=14.2, <=14.3, <=14.4, <=14.5, <=14.6, <=14.7, <=14.8, <=14.9, <=15, <=40"
val="0, 0.01, 0.0241428571, 0.0382857143, 0.0524285714, 0.0665714286, 0.0807142857, 0.0948571429, 0.109, 0.1231428571, 0.1372857143, 0.1514285714, 0.1655714286, 0.1797142857, 0.1938571429, 0.208, 0.2221428571, 0.2362857143, 0.2504285714, 0.2645714286, 0.2787142857, 0.2928571429, 0.307, 0.3211428571, 0.3352857143, 0.3494285714, 0.3635714286, 0.3777142857, 0.3918571429, 0.406, 0.4201428571, 0.4342857143, 0.4484285714, 0.4625714286, 0.4767142857, 0.4908571429, 0.505, 0.5191428571, 0.5332857143, 0.5474285714, 0.5615714286, 0.5757142857, 0.5898571429, 0.604, 0.6181428571, 0.6322857143, 0.6464285714, 0.6605714286, 0.6747142857, 0.6888571429, 0.703, 0.7171428571, 0.7312857143, 0.7454285714, 0.7595714286, 0.7737142857, 0.7878571429, 0.802, 0.8161428571, 0.8302857143, 0.8444285714, 0.8585714286, 0.8727142857, 0.8868571429, 0.901, 0.9151428571, 0.9292857143, 0.9434285714, 0.9575714286, 0.9717142857, 0.9858571429, 1, 1"

#reclass according to class and val
for file in `ls $download_dir/crop/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
python /path/to/gdal_reclassify.py $download_dir/crop/$file $download_dir/SI/${file%.tif}_SI.tif -c "$class" -r "$val" -d 0 -n true -p "COMPRESS=DEFLATE"
done

#this part generate the global habitat suitability index (HSI)
#Black_Sea_EMODNET_cold.tif and Black_Sea_EMODNET_warm.tif represent a reclassified bathymetry with
#values from 0 (lees favourable) to 1 (very favourable)

d=2017-01-01
for i in {1..1095}
do

declare -i current_date=${d:6:1}

#echo $current_date
if [ $current_date -ge 4 ] && [ $current_date -le 9 ]
then
	bathymetry='/path/to/summer/bathymetry_SI/Black_Sea_EMODNET_warm.tif'
else
	bathymetry='/path/to/winter/bathymetry_SI/Black_Sea_EMODNET_cold.tif'
fi

SI_SST=/path/to/daily/SST_SI/SST_${d}_SI.tif

SI_SSS=/path/to/daily/SSS_SI/SSS_${d}_SI.tif

output_HSI=/path/to/output/HSI/HSI_${d}.tif

if [ $current_date -ge 4 ] && [ $current_date -le 9 ]
then
	gdal_calc.py -A $bathymetry -B $SI_SSS -C $SI_SST --overwrite --type='Float32' --NoDataValue=0 --outfile=$output_HSI --calc="(A*0.33)+(B*0.55)+(C*0.12)"
else
	gdal_calc.py -A $bathymetry -B $SI_SSS -C $SI_SST --overwrite --type='Float32' --NoDataValue=0 --outfile=$output_HSI --calc="A*0.38+B*0.49+C*0.13"
fi
d=$(date -I -d "$d + 1 day")
done
