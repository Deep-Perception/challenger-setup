#!/bin/bash

docker compose -f ../docker-compose.yaml down 
docker compose -f ../docker-compose.yaml pull
