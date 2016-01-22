echo "### create consul server nodes..."

docker-machine create -d virtualbox node1 && \
  docker-machine create -d virtualbox node2 && \
  docker-machine create -d virtualbox node3

echo "### install consul and registrator..."

eval $(docker-machine env node1)

docker run -d -v /mnt:/data --name=consul \
  -p 8300:8300 \
  -p 8301:8301 \
  -p 8301:8301/udp \
  -p 8302:8302 \
  -p 8302:8302/udp \
  -p 8400:8400 \
  -p 8500:8500 \
  -p 53:8600/udp \
  gliderlabs/consul-server:0.6 -server -advertise $(docker-machine ip node1) \
  -client 0.0.0.0 -bootstrap-expect 3

docker run -d \
  --name=registrator \
  --net=host \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    consul://$(docker-machine ip node1):8500

eval $(docker-machine env node2)

docker run -d -v /mnt:/data --name=consul \
  -p 8300:8300 \
  -p 8301:8301 \
  -p 8301:8301/udp \
  -p 8302:8302 \
  -p 8302:8302/udp \
  -p 8400:8400 \
  -p 8500:8500 \
  -p 53:8600/udp \
  gliderlabs/consul-server:0.6 -server -advertise $(docker-machine ip node2) \
  -client 0.0.0.0 -join $(docker-machine ip node1)

docker run -d \
  --name=registrator \
  --net=host \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    consul://$(docker-machine ip node2):8500

eval $(docker-machine env node3)

docker run -d -v /mnt:/data --name=consul \
  -p 8300:8300 \
  -p 8301:8301 \
  -p 8301:8301/udp \
  -p 8302:8302 \
  -p 8302:8302/udp \
  -p 8400:8400 \
  -p 8500:8500 \
  -p 53:8600/udp \
  gliderlabs/consul-server:0.6 -server -advertise $(docker-machine ip node3) \
  -client 0.0.0.0 -join $(docker-machine ip node1)

docker run -d \
  --name=registrator \
  --net=host \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    consul://$(docker-machine ip node3):8500

echo "### test consul dns..."

dig @$(docker-machine ip node1) consul.service.consul

echo "### set up swarm..."

docker-machine create --driver virtualbox --swarm --swarm-master \
  --swarm-discovery consul://$(docker-machine ip node1):8500/ swarm-master

docker-machine create --driver virtualbox --swarm --swarm-discovery \
  consul://$(docker-machine ip node1):8500/ swarm1

docker-machine create --driver virtualbox --swarm --swarm-discovery \
  consul://$(docker-machine ip node1):8500/ swarm2

eval $(docker-machine env swarm-master)

docker run \
  -p 8300:8300 \
  -p 8301:8301 \
  -p 8301:8301/udp \
  -p 8302:8302 \
  -p 8302:8302/udp \
  -p 8400:8400 \
  -p 8500:8500 \
  -p 53:8600/udp \
  -d -v /mnt:/data \
  gliderlabs/consul-server:0.6 -advertise $(docker-machine ip swarm-master) \
  -client 0.0.0.0 -join $(docker-machine ip node1)

eval $(docker-machine env swarm1)

docker run \
  -p 8300:8300 \
  -p 8301:8301 \
  -p 8301:8301/udp \
  -p 8302:8302 \
  -p 8302:8302/udp \
  -p 8400:8400 \
  -p 8500:8500 \
  -p 53:8600/udp \
  -d -v /mnt:/data \
  gliderlabs/consul-server:0.6 -advertise $(docker-machine ip swarm1) \
  -client 0.0.0.0 -join $(docker-machine ip node1)

eval $(docker-machine env swarm2)

docker run \
  -p 8300:8300 \
  -p 8301:8301 \
  -p 8301:8301/udp \
  -p 8302:8302 \
  -p 8302:8302/udp \
  -p 8400:8400 \
  -p 8500:8500 \
  -p 53:8600/udp \
  -d -v /mnt:/data \
  gliderlabs/consul-server:0.6 -advertise $(docker-machine ip swarm2) \
  -client 0.0.0.0 -join $(docker-machine ip node1)

echo "### install registrator on swarm"
eval "$(docker-machine env --swarm swarm-master)"

docker run -d \
  -e constraint:node==swarm-master \
  --net=host \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    -ip $(docker-machine ip swarm-master) \
    consul://$(docker-machine ip swarm-master):8500

docker run -d \
  -e constraint:node==swarm1 \
  --net=host \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    -ip $(docker-machine ip swarm1) \
    consul://$(docker-machine ip swarm1):8500

docker run -d \
  -e constraint:node==swarm2 \
  --net=host \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    -ip $(docker-machine ip swarm2) \
    consul://$(docker-machine ip swarm2):8500

echo "### install a web service"
eval "$(docker-machine env --swarm swarm-master)"
docker run -d -P asakaguchi/docker-nodejs-hello-world

echo "### check the swarm"
eval "$(docker-machine env --swarm swarm-master)"
docker info
docker ps

echo "### build nginx-data image"
eval $(docker-machine env swarm-master)
cd nginx-data/etc/consul-template
docker build --rm -t eevenson/nginx-data .
cd ../../..

eval $(docker-machine env --swarm swarm-master)
CONT_ID=$(docker run -d -e constraint:node==swarm-master eevenson/nginx-data)

docker run -d --volumes-from $CONT_ID -p 80:80 -p 443:443 \
  --dns=172.17.0.1 \
  -e constraint:node==swarm-master seges/nginx-consul:1.9.9
