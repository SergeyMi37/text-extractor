ARG IMAGE=intersystemsdc/iris-community:latest
FROM $IMAGE

USER root

RUN apt-get update && \
    apt-get install -yq tesseract-ocr && \
    apt-get install -yq poppler-utils && \
    apt-get install tesseract-ocr-rus

USER ${ISC_PACKAGE_MGRUSER}

WORKDIR /home/irisowner/dev

ARG TESTS=0
ARG MODULE="pdf-text-extract"
ARG NAMESPACE="USER"

# create Python env
## Embedded Python environment
ENV IRISUSERNAME "SuperUser"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE "USER"
ENV PYTHON_PATH=/usr/irissys/bin/
ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

## Start IRIS

RUN --mount=type=bind,src=.,dst=. \
    pip3 install -r requirements.txt && \
    iris start IRIS && \
	iris session IRIS < iris.script && \
    ([ $TESTS -eq 0 ] || iris session iris -U $NAMESPACE "##class(%ZPM.PackageManager).Shell(\"test $MODULE -v -only\",1,1)") && \
    iris stop IRIS quietly
