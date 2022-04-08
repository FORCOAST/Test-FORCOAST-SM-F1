##Publish a single GeoTiff

#create GeoServer datastore
curl -u admin:#33f0rc0ast -v -XPOST -H "Content-type: text/xml" -d "<coverageStore><name>test_raster</name><title>Test raster title</title><enabled>true</enabled><type>GeoTIFF</type><url>/storage/forcoast/tmp/20210901.tif</url><workspace>test</workspace></coverageStore>" https://forecoast.apps.k.terrasigna.com/geoserver/rest/workspaces/test/coveragestores

#publish layer to GeoServer
curl -u admin:#33f0rc0ast -v -XPOST -H "Content-type: text/xml" -d "<coverage><nativeName>20210901</nativeName><name>test_raster_layer</name><title>Test Layer title</title></coverage>" https://forecoast.apps.k.terrasigna.com/geoserver/rest/workspaces/test/coveragestores/test_raster/coverages

#attach SLD
curl -u admin:#33f0rc0ast -v -XPUT -H "Content-type: text/xml" -d "<layer><defaultStyle><name>test:test_sld</name></defaultStyle></layer>" https://forecoast.apps.k.terrasigna.com/geoserver/rest/layers/test_raster_layer


##Dealing with styles

#upload a style to GeoServer
curl -u admin:#33f0rc0ast -XPOST -H 'Content-type:application/zip' -T color_ramp.zip https://forecoast.apps.k.terrasigna.com/geoserver/rest/workspaces/test/styles
