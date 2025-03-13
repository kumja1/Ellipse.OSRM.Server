FROM ghcr.io/project-osrm/osrm-backend:v5.27.1 as builder

ARG PBF_URL=https://download.geofabrik.de/north-america/us/virginia-latest.osm.pbf
WORKDIR /data
RUN apt-get update && apt-get install -y aria2 && \
    aria2c -s16 -x16 -k1M --dir=/data ${PBF_URL} -o region.osm.pbf || \
    wget ${PBF_URL} -O region.osm.pbf

RUN osrm-extract -p /opt/car.lua region.osm.pbf && \
    osrm-partition region.osm && \
    osrm-customize region.osm

FROM ghcr.io/project-osrm/osrm-backend:v5.27.1
COPY --from=builder /data/region.osrm* /data/
EXPOSE 5000
ENTRYPOINT ["osrm-routed", "--algorithm", "mld", "/data/region.osrm"]