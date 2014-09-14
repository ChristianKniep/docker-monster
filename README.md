docker-monster
==========

Docker Image that holds everything needed to sneak into monitoring... :)

- **ELK** The Elasticsearch/Logstash/Kibana stack to handle log events
- **carbon2grafana** The carbon engine exposed by graphite-api and visualized by grafana
- **statsd** The metrics cache StatsD
- **diamond** Metric are collected by diamond.

## Start
```
# To get all the /dev/* devices needed for sshd and alike:
export DEV_MOUNTS="-v /dev/null:/dev/null -v /dev/urandom:/dev/urandom -v /dev/random:/dev/random"
export DEV_MOUNTS="${DEV_MOUNTS} -v /dev/full:/dev/full -v /dev/zero:/dev/zero"
# if you want to store data outside of the CoW-FS
export NO_COW="-v /var/lib/carbon/whisper -v /var/lib/elasticsearch"

docker run -d -h monster --name monster --privileged \
     --privileged  ${DEV_MOUNTS} ${NO_COW} \
     -p 9200:9200 -p 88:88 -p 5514:5514 -p 80:80 \
     qnib/monster:latest
```


