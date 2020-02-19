#!/usr/bin/env bash
#
# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

docker kill influxdb_v2 || true
docker rm influxdb_v2 || true

docker kill vector || true
docker rm vector || true

docker kill web || true
docker rm web || true

docker kill ab || true
docker rm ab || true

docker network rm influx_network || true
docker network create -d bridge influx_network --subnet 192.168.0.0/24 --gateway 192.168.0.1

##
## Start InfluxDB 2
##
docker run \
       --detach \
       --name influxdb_v2 \
       --network influx_network \
       --publish 9999:9999 \
       quay.io/influxdb/influxdb:2.0.0-beta

echo "Wait to start InfluxDB 2.0"
wget -S --spider --tries=20 --retry-connrefused --waitretry=5 http://localhost:9999/metrics

##
## Post onBoarding request to InfluxDB 2
##
curl -i -X POST http://localhost:9999/api/v2/setup -H 'accept: application/json' \
    -d '{
            "username": "my-user",
            "password": "my-password",
            "org": "my-org",
            "bucket": "my-bucket",
            "token": "my-token"
        }'

docker run \
       --detach \
       --name vector \
       --network influx_network \
       --publish 5140:5140/udp \
       --volume "${SCRIPT_PATH}"/vector.toml:/etc/vector/vector.toml:ro \
       timberio/vector:nightly-2020-02-19-alpine

##
## Start WebApp
##
docker run \
       --detach \
       --name web \
       --network influx_network \
       --volume "${SCRIPT_PATH}"/web/httpd.conf:/usr/local/apache2/conf/httpd.conf \
       --publish 8080:80 \
       --log-driver=syslog\
       --log-opt syslog-address=udp://localhost:5140 \
       httpd

echo "Wait to start WebApp"
wget -S --spider --tries=20 --retry-connrefused --waitretry=5 http://localhost:8080

##
## Run Apache Benchmark to simulate load
##
docker run \
        --detach \
        --name ab \
        --network influx_network \
        --volume "${SCRIPT_PATH}"/ab/urls.txt:/tmp/urls.txt \
        --volume "${SCRIPT_PATH}"/ab/load.sh:/tmp/load.sh \
        russmckendrick/ab bash /tmp/load.sh

docker logs -f vector
