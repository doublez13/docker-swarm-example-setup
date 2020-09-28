# Docker Swarm Reverse Proxy Example Setup
This is an example setup along with example configs for setting up Docker Swarm. This is really just an organized collection of my notes and configs, but others can use these as a starting point. This leverages Traefik, an open source reverse proxy and load balancing software written in Go. Traefik can also automatically handle certificate generation and renewal using the ACME protocol. These examples use Let's Encrypt as the certificate provider. 

![alt text](https://github.com/doublez13/docker-swarm-example-setup/blob/master/example-architecture.jpg)

## Components:
**Docker Swarm:** Container-orchestration system  
**Traefik:** Reverse proxy and certificate manager  
**Keepalived:** Uses VRRP to assign one floating IP address to the swarm  
**NFS:** Stores Docker volumes on NFS so they're accessible on any node

## Docker Swarm:
## Traefik:
### Docker Socket Proxy (optional):
As Traefik needs to be aware of containers stopping and starting, it uses the docker socket file for communication. Although the docker socket can be bind mounted directly into the Traefik container (and is shown in the official Traefik docker examples), this is not recommended, as Traefik essentially has root on the docker host. Additionally, adding the `ro` mount option on the docker socket doesn't protect againt much either.  

One way to mitigate the risks is to wrap the docker socket with a proxy, and then route all docker socket communication through that. For this, we'll be using the popular [docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy). Using docker-socket-proxy, by default most requests are blocked. This includes all requests that are not GET. For Traefik to function, we'll need to open up a few additional docker socket endpoints.  

## Keepalived:
When exposing a port in Docker swarm, that port is exposed on all nodes. An external load balancer is often used to balace the requests among the swarm nodes. One benefit is that a load balancer can often check the health of a node, and stop sending it requests if it detects a problem. Docker swarm may be able to move your containers to another host if a problem is detected, but this is pointless if any DNS entries point to the problem node. This example does not make use of a load balancer, but instead relies on the [Virtual Router Redundancy Protocol](https://en.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol) (VRRP). VRRP allows all nodes in the cluster to share one or more IP addresses. This "virtual address" can live on it's own interface, or share the interface associated with the node's primary address. Only one node in the cluster has the IP address at any one time. If that host goes offline, the IP address is migrated over to another host in a matter of seconds. This example uses keepalived to implement VRRP. In the example coniguration provided, keepalived monitors the docker service.

## NFS:
