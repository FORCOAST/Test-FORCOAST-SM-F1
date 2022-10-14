# ForCoast-SM-F1

### Description

This services uses water temperature and salinity to calculate an index (HSI) for the localization of the optimal condition for fishing activities. The service is run every day and the results can be found in the Data viewer tab.

### How to run

* Containerize contents in docker
* Run the command Docker run forcoast/forcoast-sm-f1 &lt;weight bathymetry> &lt;weight salinity> &lt;weight temperature> &lt;Lonmax> &lt;Latmax> &lt;Lonmin> &lt;Latmin> &lt;usrname> &lt;psw> &lt;token> &lt;chat_id>
  * Where the weights are given for their importance in calculating the index
  * usrname and psw are the username and password for Geoserver
  * Mode is how the sources and targets input are given
  * Token and chat_id are for sending bulletins through Telegram messagin servic
* Example of use: Docker run forcoast-sm-f1 0.33 0.55 0.12 27.43 41.99 31.35 45.21 usrname psw 5267228188:AAGx60FtWgHkScBb3ISFL1dp6Oq_9z9z0rw -1001621401692

### Licence

Licensed under the Apache License, Version 2.0
