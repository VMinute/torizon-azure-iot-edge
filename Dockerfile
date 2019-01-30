FROM arm32v7/debian:stretch-slim

ARG APT_PROXY

#if argument APT_PROXY is configured, it will be used to speed-up download of deb packages
RUN if [ "$APT_PROXY" != "" ]; then \
    echo "Acquire::http::Proxy \"http://$APT_PROXY:8000\";" > /etc/apt/apt.conf.d/30proxy ;\
    echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy ; \
    echo "squid-deb-proxy configured"; \
    else \
    echo "no squid-deb-proxy configured"; \
    fi

# those RUN statements are going to be executed using emulation on an x86 machine
# please note that if you need to keep container small is better to pack apt-get update, install and
# cache cleanup (rm -rf /var/lib/apt/lists/*) in a single docker file statement as described here:
# https://docs.docker.com/v17.09/engine/userguide/eng-image/dockerfile_best-practices/#run
RUN apt-get -q -y update && apt-get install -q -y --no-install-recommends curl ca-certificates libssl1.0 && rm -rf /var/lib/apt/lists/*

# remove proxy so container will run on any host
RUN if [ "$APT_PROXY" != "" ]; then rm /etc/apt/apt.conf.d/30proxy; fi

# just create a docker group and add a user to it, to keep installer happy
# we are going to use runtime on the device
RUN groupadd docker
RUN usermod -a -G docker root

# Download and install the standard libiothsm implementation
RUN curl -L https://aka.ms/libiothsm-std-linux-armhf-latest -o libiothsm-std.deb && dpkg -i ./libiothsm-std.deb

# Download and install the IoT Edge Security Daemon
RUN curl -L https://aka.ms/iotedged-linux-armhf-latest -o iotedge.deb && dpkg -i ./iotedge.deb

# Run apt-get fix
RUN apt-get -q -y install -f

EXPOSE 8080
EXPOSE 8081

CMD iotedged -c /etc/iotedge/config.yaml
