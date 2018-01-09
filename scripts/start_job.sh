#!/bin/bash

curl -v -d "action=build" -k -u admin:admin --anyauth --location https://localhost:8443/engine/job/govbr-crawler
curl -v -d "action=launch" -k -u admin:admin --anyauth --location https://localhost:8443/engine/job/govbr-crawler
curl -v -d "action=unpause" -k -u admin:admin --anyauth --location https://localhost:8443/engine/job/govbr-crawler
