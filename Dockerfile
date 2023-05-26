ARG IMAGE=intersystemsdc/irishealth-community
ARG IMAGE=intersystemsdc/iris-community
# ARG IMAGE=containers.intersystems.com/intersystems/iris:2021.1.0.215.0
FROM $IMAGE

USER root   
## add git
RUN apt update && apt-get -y install git
        
WORKDIR /opt/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild
USER ${ISC_PACKAGE_MGRUSER}

#COPY  Installer.cls .
COPY  src src
COPY module.xml module.xml
COPY iris.script iris.script

COPY iris.key /usr/irissys/mgr/iris.key

RUN iris start IRIS \
	&& iris session IRIS < iris.script \
    && iris stop IRIS quietly
