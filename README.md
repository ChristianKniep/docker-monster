docker-monster
==========

Docker Image that holds everything needed to sneak into monitoring... :)

- **ELK** The Elasticsearch/Logstash/Kibana3/Kibana4 stack to handle log events
- **carbon** The carbon engine...
- **graphite-api** ...exposed by graphite-api and visualized by...
- **grafana** 
- **statsd** The metrics cache StatsD
- **diamond** Metric are collected by diamond.

## Start
```
docker-compose up -d
# visit http://<docker_server>:8500 to see the services coming up
# to 'log into' the container
docker exec -ti dockermonster_monster_1 bash
```


