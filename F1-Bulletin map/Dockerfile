FROM osgeo/gdal:ubuntu-full-3.4.3

COPY . /usr/src/app

RUN apt-get update
RUN apt install gnupg software-properties-common -y
RUN apt-get install wget
RUN apt install -y zip
RUN apt install curl -y
RUN apt-get install sudo -y
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

ENTRYPOINT ["python3", "/usr/src/app/Map_generator_docker.py"]
