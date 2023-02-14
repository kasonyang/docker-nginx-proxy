# Overview

A reserve proxy base on nginx with the following features:

* Request ssl certificates automatically using [acme.sh](https://github.com/acmesh-official/acme.sh ).
* Easy to configure.
* Reload automatically after configuration changed.

# Usage

```
mkdir data
mkdir vhosts
```

Create a file named `<YOUR DOMAIN>.toml` (e.g. `www.example.com.toml`) in the `vhosts` directory with the following content:

```
# Assume that your business server is listen on 192.168.1.100:8080
upstream = ["192.168.1.100:8080"]
```

Then run:

```
docker run -d --name nginx-proxy \
       -v ./vhosts:/etc/nginx-proxy/vhosts:ro \
       -v ./data:/var/nginx-proxy \
       -p 80:80 \
       kasonyang/nginx-proxy:latest
```

#  Request ssl certificates automatically

To make https available without extra ssl certificates, you could enable `AUTO_SSL` feature.

The container will request free ssl certificates automatically on container starting or new domain added.

**Important:** please replace `<YOUR_EMAIL>` to **your email** before running the following command.

```
docker run -d --name nginx-proxy \
       --env AUTO_SSL=on \
       --env AUTO_SSL_EMAIL=<YOUR_EMAIL> \
       -v ./vhosts:/etc/nginx-proxy/vhosts:ro \
       -v ./data:/var/nginx-proxy \
       -p 80:80 \
       -p 443:443 \
       kasonyang/nginx-proxy:latest
```

# Relate Project

* [tpl-gen](https://github.com/kasonyang/tpl-gen)
* [run-on-change](https://github.com/kasonyang/run-on-change)

# LICENSE

MIT