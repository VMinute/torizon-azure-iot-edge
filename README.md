# Azure IoT Edge container

This is a container used to run azure-iot-edge.  
The command line to start it on a torizon device is:  
docker run --name edgeDaemon --network host --rm -it -v /home/torizon/config.yaml:/etc/iotedge/config.yaml -v /var/run/iotedge:/var/run/iotedge -v /var/run/docker.sock:/var/run/docker.sock valterminute/azure-iot-edge

You need to create the /var/run/iotedge subfolder:
sudo mkdir -p /var/run/iotedge

And to provide a valid config.yaml file (see config.yaml.template for an example)

