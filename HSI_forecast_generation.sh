#!/bin/bash

CURRENT_DIR="$(pwd)"
GEOSERVER_ENDPOINT="$4"
GEOSERVER_USER="$5"
GEOSERVER_PASSWORD="$6"

DATA_DIR=/usr/src/app/data

#assign the bathymetry by bate
declare -i current_date=$(date +%m) #declare variable as int
#echo $current_date
if [ $current_date -ge 4 ] && [ $current_date -le 9 ]
then
	bathymetry=$DATA_DIR/Black_Sea_EMODNET_warm.tif
else
	bathymetry=$DATA_DIR/Black_Sea_EMODNET_cold.tif
fi

#create SI for SST and SSS
bash /usr/src/app/HSI_SSS_forecast.sh
bash /usr/src/app/HSI_SST_forecast.sh

#calculate HSI from SI
for file in `ls $DATA_DIR/download/tem/SI/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
#echo $file
SI_SST=$DATA_DIR/download/tem/SI/$file
#echo $SI_SST
SI_SSS=$DATA_DIR/download/sal/SI/sv03_bs_cmcc_sal_an_fc_d_${file:26:8}_SI.tif
#echo $SI_SSS
HSI_whiting=$(date +%Y%m%dT000000000Z)
output_HSI=/usr/src/app/$HSI_whiting.tif
if [ $current_date -ge 4 ] && [ $current_date -le 9 ]
then
	gdal_calc.py -A $bathymetry -B $SI_SSS -C $SI_SST --overwrite --type='Float32' --NoDataValue=0 --outfile=$output_HSI --calc="(A*$1)+(B*$2)+(C*$3)"
else
	gdal_calc.py -A $bathymetry -B $SI_SSS -C $SI_SST --overwrite --type='Float32' --NoDataValue=0 --outfile=$output_HSI --calc="A*$1+B*$2+C*$3"
fi
done

gdaladdo -r gauss /usr/src/app/$HSI_whiting.tif 2 4 8 16 32 64 128

rm -rf $DATA_DIR/download/*.tif
rm -rf $DATA_DIR/download/*.nc

STORAGE_OUT_DIR="${WPS_OUTPUT_result}"

# Upload file to minio
mc alias set forcoast-minio https://minio.apps.k.terrasigna.com forcoast viet6iechijofoNgua3kei
mc cp /usr/src/app/$HSI_whiting.tif forcoast-minio/forcoast/$HSI_whiting.tif
LINK_TO_FILE="https://minio.apps.k.terrasigna.com/forcoast/$HSI_whiting.tif"

cp ${STORAGE_OUT_DIR}/$HSI_whiting.tif $CURRENT_DIR

#zip tif file
zip HSI_whiting.zip -j /usr/src/app/$HSI_whiting.tif

echo '{
  "import": {
    "targetWorkspace": {
      "workspace": {
        "name": "test"
      }
    },
    "data": {
      "type": "remote",
      "location": "'${LINK_TO_FILE}'"
    }
  }
}
' > ${STORAGE_OUT_DIR}/import.json

#curl -u "admin:#33f0rc0ast" -XPOST -H "Content-type: application/json" -d @${STORAGE_OUT_DIR}/import.json "https://forecoast.apps.k.terrasigna.com/geoserver/rest/imports?async=true&exec=true"
curl -u "admin:#33f0rc0ast" -XPOST -H "Content-type:application/zip" -T "/usr/src/app/HSI_whiting.zip" "https://forecoast.apps.k.terrasigna.com/geoserver/rest/workspaces/forcoast/coveragestores/HSI_whiting/file.imagemosaic?recalculate=nativebbox.latlonbbox"
exit 0
