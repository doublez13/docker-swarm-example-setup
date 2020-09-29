# Docker Swarm Reverse Proxy Example Setup
This is a very basic setup (with example configs) for setting up a "self-healing" Docker Swarm. This is really just an organized collection of my notes and configs, but others can use these as a starting point. This leverages Traefik, an open source reverse proxy and load balancing software written in Go.

![alt text](https://github.com/doublez13/docker-swarm-example-setup/blob/master/example-architecture.jpg)

## Components:
**Docker Swarm:** Container-orchestration system  
**Traefik:** Reverse proxy and certificate manager  
**Keepalived:** Uses VRRP to assign one floating IP address to the swarm  
**NFS:** Stores Docker volumes on NFS so they're accessible on any node

## Docker Swarm:
ToDo

An external docker overlay network needs to be created for the web servers and proxy to attach to.  
`docker network create --driver overlay web-servers`


## Traefik:
Traefik is a modern HTTP reverse proxy server with [many other interesting features](https://doc.traefik.io/traefik/middlewares/overview/). Traefik can be thought of as an ingress controller (if you're coming from a Kubernetes mindset). In this example, we put Traefik in front of our web containers, and let it handle the routing based on Server Name Indication. Although not required, it's nearly effortless to hook Let's Encrypt into Traefik for automatied certificates, and we'll do that in the examples. Traefik can also handle some more advanced configurations, like load balancing beween multiple service replicas.

### Docker Socket Proxy (optional):
As Traefik needs to be aware of containers stopping and starting, it uses the docker socket file for communication. Although the docker socket can be bind mounted directly into the Traefik container (and is shown in the [official Traefik Docker examples](https://doc.traefik.io/traefik/user-guides/docker-compose/basic-example/)), this is not recommended, as Traefik essentially has root on the docker host. Additionally, adding the `ro` mount option on the docker socket doesn't protect againt much either.  

One way to mitigate the risks is to wrap the docker socket with a proxy that only allows a subset of commands, and then route all docker socket communication through that. For this, we'll be using the popular [docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy). Using docker-socket-proxy, by default most requests are blocked. This includes all non-GET requests. For Traefik to function, we'll need to open up a few additional docker socket endpoints. Finally, we'll make the network that the docker socket proxy lives on internal, and attach only the Traefik container to it.  

## Keepalived:
Docker swarm may be able to move your containers to another node if a problem is detected, but this is useless if any DNS entries point to the problem node. When exposing a port in Docker swarm, that port is exposed on all nodes. An external load balancer is often used to balace the requests among the swarm nodes. One benefit is that a load balancer can often check the health of a node, and stop sending it requests if it detects a problem. But again, the load balancer becomes a single point of failure. In this example, we'll be using VRRP ([Virtual Router Redundancy Protocol](https://en.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol)). VRRP allows all nodes in the cluster to share one (or more) IP addresses. This "virtual address" can live on it's own interface, or share the interface associated with the node's primary address. Only one node in the cluster has the IP address at any one time. If that node goes offline, the IP address seamlessly migrates to another node in a matter of seconds. This example uses keepalived to implement VRRP. In the [example coniguration provided](https://github.com/doublez13/docker-swarm-example-setup/blob/master/keepalived/keepalived.conf), keepalived monitors the docker service.

## NFS:
There are many third party Docker volume drivers out there. For this setup, I'm just using the local driver to NFS mount docker volumes. I have seen some mixed feedback on this, but my understanding is as follows. Do **NOT** NFS mount the docker volumes directory (/var/lib/docker/volumes). This is just asking for trouble when two different docker daemons think they have owership. However, I have seen no problems using the local driver with type set to NFS. Docker automatically mounts and unmounts the volumes inside the docker volumes directory. Check out the wordpress compose file for an example.
