# Docker Swarm Example Setup
This is an example setup along with example configs for setting up Docker swarm.

![alt text](https://github.com/doublez13/docker-swarm-example-setup/blob/master/example-architecture.jpg)

## Components Used
**Docker Swarm:** Container-orchestration system  
**Traefik:** Reverse proxy and certificate manager  
**Keepalived:** Uses VRRP to assign one floating IP address to the swarm  
**NFS:** Stores Docker volumes on NFS so they're accessible on any node
