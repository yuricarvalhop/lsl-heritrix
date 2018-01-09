#!/bin/bash

curl -v -d "action=pause" -k -u admin:admin --anyauth --location https://localhost:8443/engine/job/govbr-crawler
curl -v -d "action=terminate" -k -u admin:admin --anyauth --location https://localhost:8443/engine/job/govbr-crawler
curl -v -d "action=teardown" -k -u admin:admin --anyauth --location https://localhost:8443/engine/job/govbr-crawler
