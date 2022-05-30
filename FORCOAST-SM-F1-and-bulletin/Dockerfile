FROM osgeo/gdal:ubuntu-full-3.4.3

COPY . /usr/src/app

RUN apt-get update
RUN apt-get install sudo -y
RUN apt-get install gnupg -y
RUN apt-get install software-properties-common -y
RUN apt-get install wget
RUN apt-get install zip -y
RUN apt-get install curl -y
RUN wget -O /usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x /usr/local/bin/mc
RUN wget -qO - https://qgis.org/downloads/qgis-2021.gpg.key | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import
RUN chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg
RUN add-apt-repository "deb https://qgis.org/debian $(lsb_release -c -s) main"
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt-get install qgis -y 
RUN apt install python3-pip -y
RUN pip install PyQt5
RUN pip install telepot
RUN python3 -m pip install motuclient==1.8.4 --no-cache-dir

RUN chmod 755 /usr/src/app/HSI_forecast_generation.sh /usr/src/app/HSI_forecast_generation.sh /usr/src/app/HSI_forecast_generation.sh && \
    mkdir -p /usr/src/app/data/HSI && \
    mkdir -p /usr/src/app/data/download/tem/crop && \
    mkdir -p /usr/src/app/data/download/tem/SI && \
    mkdir -p /usr/src/app/data/download/sal/crop && \
    mkdir -p /usr/src/app/data/download/sal/SI

ENTRYPOINT ["/usr/src/app/HSI_forecast_generation.sh"]
