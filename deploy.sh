#!/bin/bash

client="varunamachi/fib-client"
server="varunamachi/fib-server"
worker="varunamachi/fib-worker"

docker build \
    -t "${client}:${SHA}" \
    -t ${client}:latest \
    -f ./client/Dockerfile ./client
docker build \
    -t "${server}:${SHA}" \
    -t ${server}:latest \
    -f ./server/Dockerfile ./server
docker build \
    -t "${worker}:${SHA}" \
    -t ${worker}:latest \
    -f ./worker/Dockerfile ./worker

docker push "${client}:${SHA}"
docker push "${server}:${SHA}"
docker push "${worker}:${SHA}"

docker push "${client}:latest"
docker push "${server}:latest"
docker push "${worker}:latest"

kubectl apply -f k8s

kubectl set image deployments/client-deployment client="${client}:${SHA}"
kubectl set image deployments/server-deployment server="${server}:${SHA}"
kubectl set image deployments/worker-deployment worker="${worker}:${SHA}"


