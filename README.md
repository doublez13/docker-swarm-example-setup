# Docker Swarm Reverse Proxy Example Setup
This is an example setup along with example configs for setting up Docker Swarm. This is really just an organized collection of my notes and configs, but others can use these as a starting point. This leverages Traefix, an open source reverse proxy and load balancing software written in Go. Traefix can also automatically handle certificate generation and renewal using the ACME protocol. These examples use Let's Encrypt as the certificate provider. 

![alt text](https://github.com/doublez13/docker-swarm-example-setup/blob/master/example-architecture.jpg)

## Components:
**Docker Swarm:** Container-orchestration system  
**Traefik:** Reverse proxy and certificate manager  
**Keepalived:** Uses VRRP to assign one floating IP address to the swarm  
**NFS:** Stores Docker volumes on NFS so they're accessible on any node

## Docker Swarm:
## Traefik:
### Docker Socket Proxy (optional):
As Traefix needs to be aware of containers stopping and starting, it uses the docker socket file for communication. Although the docker socket can be bind mounted directly into the Traefix container (and is shown in the official Traefix docker examples), this is not recommended, as Traefix essentially has root on the docker host. Additionally, adding the `ro` mount option on the docker socket doesn't protect againt much either.  

One way to mitigate the risks is to wrap the docker socket with a proxy, and then route all docker socket communication through that. For this, we'll be using the popular [docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy). Using docker-socket-proxy, by default most requests are blocked. This includes all requests that are not GET. For Traefik to function, we'll need to open up a few additional docker socket endpoints.  
## Keepalived:
## NFS:
