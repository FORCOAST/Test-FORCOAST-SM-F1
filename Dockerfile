FROM ubuntu:20.04

RUN apt-get update --fix-missing && \
    apt-get install -y gdal-bin && \
    apt-get install -y python3 && \
    apt install -y python3-pip curl wget && \
	apt install tzdata -y && \
	apt install -y zip
RUN wget -O /usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x /usr/local/bin/mc
RUN python3 -m pip install motuclient==1.8.4 --no-cache-dir
WORKDIR /usr/src/app
COPY HSI_forecast_generation.sh HSI_SST_forecast.sh HSI_SSS_forecast.sh gdal_reclassify.py /usr/src/app/
RUN chmod 755 /usr/src/app/HSI_forecast_generation.sh /usr/src/app/HSI_forecast_generation.sh /usr/src/app/HSI_forecast_generation.sh && \
    mkdir -p /usr/src/app/data/HSI && \
    mkdir -p /usr/src/app/data/download/tem/crop && \
    mkdir -p /usr/src/app/data/download/tem/SI && \
    mkdir -p /usr/src/app/data/download/sal/crop && \
    mkdir -p /usr/src/app/data/download/sal/SI
COPY . /usr/src/app/data/



ENTRYPOINT ["/usr/src/app/HSI_forecast_generation.sh"]
