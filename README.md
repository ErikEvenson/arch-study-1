# arch-study-1

## Set up development

Cluster on multiple hosts:
```bash
docker-machine create -d virtualbox node1 && \
  docker-machine create -d virtualbox node2 && \
  docker-machine create -d virtualbox node3 && \
  eval $(docker-machine env node1) && docker pull progrium/consul && \
  eval $(docker-machine env node2) && docker pull progrium/consul && \
  eval $(docker-machine env node3) && docker pull progrium/consul

eval $(docker-machine env node1)

docker run -d -h node1 -v /mnt:/data \
  -p $(docker-machine ip node1):8300:8300 \
  -p $(docker-machine ip node1):8301:8301 \
  -p $(docker-machine ip node1):8301:8301/udp \
  -p $(docker-machine ip node1):8302:8302 \
  -p $(docker-machine ip node1):8302:8302/udp \
  -p $(docker-machine ip node1):8400:8400 \
  -p $(docker-machine ip node1):8500:8500 \
  -p 172.17.0.1:53:53/udp \
  progrium/consul -server -advertise $(docker-machine ip node1) \
  -bootstrap-expect 3


eval $(docker-machine env node2)

docker run -h node2 \
  -p $(docker-machine ip node2):8300:8300 \
  -p $(docker-machine ip node2):8301:8301 \
  -p $(docker-machine ip node2):8301:8301/udp \
  -p $(docker-machine ip node2):8302:8302 \
  -p $(docker-machine ip node2):8302:8302/udp \
  -p $(docker-machine ip node2):8400:8400 \
  -p $(docker-machine ip node2):8500:8500 \
  -p 172.17.0.1:53:53/udp \
  -d -v /mnt:/data \
  progrium/consul -server -advertise $(docker-machine ip node2) \
  -join $(docker-machine ip node1)

eval $(docker-machine env node3)

docker run -h node3 \
  -p $(docker-machine ip node3):8300:8300 \
  -p $(docker-machine ip node3):8301:8301 \
  -p $(docker-machine ip node3):8301:8301/udp \
  -p $(docker-machine ip node3):8302:8302 \
  -p $(docker-machine ip node3):8302:8302/udp \
  -p $(docker-machine ip node3):8400:8400 \
  -p $(docker-machine ip node3):8500:8500 \
  -p 172.17.0.1:53:53/udp \
  -d -v /mnt:/data \
  progrium/consul -server -advertise $(docker-machine ip node3) \
  -join $(docker-machine ip node1)

docker-machine rm node1 node2 node3
```
