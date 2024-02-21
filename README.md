# Docker project

The goal of the project is to deploy the following application by using Docker and Docker compose. You will give us a GitHub or Gitlab link for your project.

![image](login-nuage-voting.drawio.svg)

## Mandatory version
- one Dockerfile per service that exposes the internal port of the container
- one docker-compose.yml file to deploy the stack
- adequate `depends_on`
- two networks will be defined: `front-net` and `back-net`
- a README file explaining how to configure and deploy the stack

## Optional extended version
- healthchecks on vote, redis and db services (some scripts are given in `healthcheck` directory)
- reducing the size of images
- multistage build on the worker service (.NET)


## Some elements

The base image will contain the basic tools for the language the application is written in.
You should use a tag to specify which version of the image you want to pull.
For building purposes, it is good practice to use a `slim` version of the image.
e.g. for Python `python:3.13-rc-slim`, for Node.js `node:18-slim`


### `vote` service

This is a Python web server using the Flask framework. It presents a front-end for the user to submit their votes, then write them into the Redis key-value store.

For building the Dockerfile, before starting `app.py`:
- requirements have to be copied and installed in the container
- all necessary files and directories have to be copied in the container

Port mapping:
`5000` is used inside the container (see Python code). Each instance of vote will use the external port `500x` where `x` is the instance number

### `result` service

This is a Node.js web server. The front-end presents the results of the votes. The result values are taken from the PostgreSQL database.

In the Dockerfile, before running the code:
- copy package files into the container,
- install `nodemon` with `npm install -g nodemon`
- install more requirements:
```
npm ci
npm cache clean --force
mv /usr/local/app/node_modules /node_modules
```
- set the `PORT` environment variable

Finally, run the code with `node server.js`.


### `seed` service

This is a Python and bash program used to virtually send many vote requests to the `vote` server.

First the file `make-data.py` has to be executed in the container. Second, the file `generate-votes.sh` has to be executed when starting the container.

For benchmarking, `generate-votes.sh` uses the `ab` utility which needs to be installed, through the `apache2-utils` `apt` package.

### `worker` service

This is a .NET (C#) program that reads vote submissions from Redis store, compute the result and store it in the PostgreSQL database.

It requires a little bit more work to compile and run:
- use this as a base image
```
mcr.microsoft.com/dotnet/sdk:7.0
```
  with the argument `--platform=${BUILDPLATFORM}`
- use `ARG` to define build arguments `TARGETPLATFORM`, `TARGETARCH` and `BUILDPLATFORM`. Print their values with `echo`.
- in the `source/` directory, copy all worker files form this repo and run
```
dotnet restore -a $TARGETARCH
dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore
```
The application will be built inside the `/app` directory, launch with `dotnet Worker.dll`.

For the multistage build, use this image: `mcr.microsoft.com/dotnet/runtime:7.0`.


### Redis service

This is a simple Redis service. Redis is a NOSQL database software focused on availability used for storing large volumes of data-structures (typically key-value pairs).

In order to perform healthchecks while Redis is running, there must be a volume attached to the container. You will need to mount local the repo directory `./healthchecks/` into the `/healthchecks/` directory of the container.

The check is done by executing the `redis.sh` script which uses the `curl` package.


### PostgreSQL database service

This is a simple PostgreSQL service.

The same logic applies for healthchecks, mount a volume, use `postgres.sh` for checks and install `curl`.

Moreover, in order to persist the data that comes from the votes, you need to create a Docker volume and attach it to the container.
The volume will be named `db-data` and attached to the `/var/lib/postgresql/data` directory inside the container.

### Nginx loadbalancer service

This is a simple Nginx service. At its core, Nginx is a web-server but it can also be used for other purposes such as loadbalancing, HTTP cache, reverse proxy, etc.

To configure Nginx as a loadbalancer (LB), you first need to edit accordingly the `./nginx/nginx.conf` file from this repo.
Then in the Dockerfile:
- remove the default Nginx configuration located at `/etc/nginx/conf.d/default.conf`,
- copy `./nginx/nginx.conf` into the container at the above location.


### Networking

* The Redis store, the `worker` service and the PostgreSQL database are only available inside the `back-tier` network.
* The `vote` and `result` services are on both the `front-tier` and `back-tier` network in order to (1) expose the frontend to users, and (2) communicate with the databases.
* Finally, the `seed` and Nginx loadbalancer are on the `front-tier`.

# Kubernetes project
