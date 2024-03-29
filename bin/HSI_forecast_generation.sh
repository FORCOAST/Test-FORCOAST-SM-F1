#!/bin/bash

#(C) Copyright FORCOAST H2020 project under Grant No. 870465. All rights reserved.

# Copyright notice
# --------------------------------------------------------------------
#  Copyright 2022 Terrasigna, Deltares
#   Ionut Serban, Daniel Twigt, Gido Stoop
#
#   ionut.serban@terrasigna.com, daniel.twigt@deltares.nl, gido.stoop@deltares.nl
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#
#        http://www.apache.org/licenses/LICENSE-2.0
# --------------------------------------------------------------------

INITIAL_DIR="$(pwd)"

#Bounding box
Xmax="$4"
Ymax="$5"
Xmin="$6"
Ymin="$7"

CURRENT_DIR="$(pwd)"
GEOSERVER_USER="$8"
GEOSERVER_PASSWORD="$9"

GEOSERVER_PASSWORD=${GEOSERVER_PASSWORD/'%92'/'\'}
GEOSERVER_PASSWORD=${GEOSERVER_PASSWORD/'%23'/'#'}

Token="${10}"
Chat_ID="${11}"

DATA_DIR=/usr/src/app

#assign the bathymetry by bate
declare -i current_date=$(date +%m) #declare variable as int
#echo $current_date
if [ $current_date -ge 4 ] && [ $current_date -le 9 ]
then
	bathymetry=$DATA_DIR/data/Black_Sea_EMODNET_warm.tif
else
	bathymetry=$DATA_DIR/data/Black_Sea_EMODNET_cold.tif
fi

#create SI for SST and SSS
bash /usr/src/app/bin/HSI_SSS_forecast.sh
bash /usr/src/app/bin/HSI_SST_forecast.sh

#calculate HSI from SI
for file in `ls $DATA_DIR/data/download/tem/SI/*.tif | xargs -n 1 basename` # xargs -n 1 basename takes only the basename, without entire path
do 
#echo $file
SI_SST=$DATA_DIR/data/download/tem/SI/$file
#echo $SI_SST
SI_SSS=$DATA_DIR/data/download/sal/SI/sv03_bs_cmcc_sal_an_fc_d_${file:26:8}_SI.tif
#echo $SI_SSS
HSI_whiting=$(date +%Y%m%dT000000000Z)
output_HSI=/usr/src/app/output/$HSI_whiting.tif
if [ $current_date -ge 4 ] && [ $current_date -le 9 ]
then
	gdal_calc.py -A $bathymetry -B $SI_SSS -C $SI_SST --overwrite --type='Float32' --NoDataValue=0 --outfile=$output_HSI --calc="(A*$1)+(B*$2)+(C*$3)"
else
	gdal_calc.py -A $bathymetry -B $SI_SSS -C $SI_SST --overwrite --type='Float32' --NoDataValue=0 --outfile=$output_HSI --calc="A*$1+B*$2+C*$3"
fi
done

gdaladdo -r gauss /usr/src/app/output/$HSI_whiting.tif 2 4 8 16 32 64 128

rm -rf $DATA_DIR/data/download/*.tif
rm -rf $DATA_DIR/data/download/*.nc

STORAGE_OUT_DIR="${WPS_OUTPUT_result}"

# Upload file to minio
mc alias set forcoast-minio https://minio.apps.k.terrasigna.com forcoast viet6iechijofoNgua3kei
mc cp /usr/src/app/output/$HSI_whiting.tif forcoast-minio/forcoast/$HSI_whiting.tif
LINK_TO_FILE="https://minio.apps.k.terrasigna.com/forcoast/$HSI_whiting.tif"

cp ${STORAGE_OUT_DIR}/$HSI_whiting.tif $CURRENT_DIR

#zip tif file
zip /usr/src/app/output/HSI_whiting.zip -j /usr/src/app/output/$HSI_whiting.tif

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

#curl -u "${GEOSERVER_USER}:${GEOSERVER_PASSWORD}" -XPOST -H "Content-type: application/json" -d @${STORAGE_OUT_DIR}/import.json "https://forecoast.apps.k.terrasigna.com/geoserver/rest/imports?async=true&exec=true"
curl -u "${GEOSERVER_USER}:${GEOSERVER_PASSWORD}" -XPOST -H "Content-type:application/zip" -T "/usr/src/app/output/HSI_whiting.zip" "https://forecoast.apps.k.terrasigna.com/geoserver/rest/workspaces/forcoast/coveragestores/HSI_Whiting/file.imagemosaic?recalculate=nativebbox.latlonbbox"

python3 /usr/src/app/bin/Map_generator_docker.py $HSI_whiting $Xmax $Ymax $Xmin $Ymin $Token $Chat_ID

cp /usr/src/app/output/F1-Bulletin-map.png $INITIAL_DIR

exit 0
