FROM ubuntu:18.04
MAINTAINER Art Eschenlauer, esch0041@umn.edu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y ubuntu-server
RUN apt-get upgrade -y
RUN apt-get install -y cvs s3cmd
RUN curl https://get.docker.com/ | sh
COPY s3 /opt/s3
COPY support /opt/support
COPY init /opt/init
RUN chmod +x /opt/init
ENTRYPOINT ["/opt/init"]
COPY Dockerfile /Dockerfile
RUN ln -s /opt/init /usr/local/bin/tardis
