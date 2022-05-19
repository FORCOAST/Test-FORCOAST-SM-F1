This folder contains files for building an image that produces the HSI-whiting fishing index and creates and sends a bulletin with a map of this indexa and <br/>
	updates the imagemosaic in the Geoserver (only if the same extent is given as in the geoserver, 27.4427 46.8495 32.4365 42.1766). <br/>
This index and bulletin will be generated on a daily basis. <br/>
Arguments can be passed in the command line in the form of: <br/>
<br/>
weight_bathymetry weight_salinity weight_temperature Lonmax Latmax Lonmin Latmin usrname psw token chat_id <br/>

Example of use: <br/>
docker run forcoast-sm-f1 0.33 0.55 0.12 27.43 41.99 31.35 45.21 usrname psw 5267228188:AAGx60FtWgHkScBb3ISFL1dp6Oq_9z9z0rw -1001621401692

