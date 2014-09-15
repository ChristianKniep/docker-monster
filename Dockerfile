###### compute node
# runs slurmd, sshd and is able to execute jobs via mpi
FROM qnib/terminal
MAINTAINER "Christian Kniep <christian@qnib.org>"

ADD etc/yum.repos.d/ /etc/yum.repos.d/
RUN yum clean all

########################
# carbon
RUN yum install -y python-carbon git-core
RUN mkdir -p /var/lib/carbon/{whisper,lists}
RUN chown carbon -R /var/lib/carbon/whisper/
## Carbon config
ADD etc/carbon/ /etc/carbon/
RUN touch /etc/carbon/aggregation-rules.conf
RUN touch /etc/carbon/storage-aggregation.conf

########################
### ELK
# which is needed by bin/logstash :)
RUN yum install -y which zeromq
RUN ln -s /usr/lib64/libzmq.so.1 /usr/lib64/libzmq.so
## kibana && nginx
RUN yum install -y nginx
WORKDIR /opt/
RUN wget --quiet https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz
RUN tar xf kibana-3.1.0.tar.gz
WORKDIR /etc/nginx/conf.d
ADD etc/nginx/conf.d/kibana.conf /etc/nginx/conf.d/kibana.conf
RUN mkdir -p /var/www
RUN ln -s /opt/kibana-3.1.0 /var/www/kibana
WORKDIR /etc/nginx/
RUN if ! grep "daemon off" nginx.conf ;then sed -i '/worker_processes.*/a daemon off;' nginx.conf;fi
# logstash
RUN useradd jls
RUN yum install -y logstash
# elasticsearch
RUN yum install -y elasticsearch
RUN sed -i '/# cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml
ADD etc/diamond/collectors/ElasticSearchCollector.conf /etc/diamond/collectors/ElasticSearchCollector.conf

# statsd
RUN yum install -y qnib-statsd
# qnib-grok
RUN yum install -y qnib-grok-patterns
# logstash-conf
RUN yum install -y qnib-logstash-conf
# Config kibana-Dashboards
ADD opt/kibana-3.1.0/app/dashboards/ /opt/kibana-3.1.0/app/dashboards/

########################
## graphite-api
RUN yum install -y --disablerepo=* --enablerepo=qnib-pip python-babel
RUN yum install -y python-graphite-api python-pyparsing python-pyyaml python-structlog python-pytz

ADD etc/graphite-api.yaml /etc/graphite-api.yaml
RUN mkdir -p /var/lib/graphite

## Diamond
ADD etc/diamond/collectors/NginxCollector.conf /etc/diamond/collectors/NginxCollector.conf

# gunicorn
RUN yum install -y python-gunicorn 
ADD etc/nginx/conf.d/diamond.conf /etc/nginx/conf.d/
#ADD etc/nginx/conf.d/graphite-api.conf /etc/nginx/conf.d/
## nginx config for gapi
ADD etc/nginx_gapi/ /etc/nginx_gapi/

#### ETCD INST
RUN yum install -y qnib-etcd
RUN mkdir -p /var/lib/etcd
ADD etc/supervisord.d/etcd.ini /etc/supervisord.d/etcd.ini
ADD root/bin/start_etcd.sh /root/bin/start_etcd.sh

########################
# GRAFANA
ADD etc/nginx/conf.d/grafana.conf /etc/nginx/conf.d/

# Grafana
WORKDIR /opt
RUN wget --quiet http://grafanarel.s3.amazonaws.com/grafana-1.8.0-rc1.tar.gz
RUN tar xf grafana-1.8.0-rc1.tar.gz 
ADD opt/grafana/config.sample.js /opt/grafana-1.8.0-rc1/config.js
RUN mkdir -p /var/www
RUN ln -s /opt/grafana-1.8.0-rc1 /var/www/grafana
ADD opt/grafana/app/dashboards/ /var/www/grafana/app/dashboards/

## Put all supervisor scripts in
ADD etc/supervisord.d/ /etc/supervisord.d/

CMD /bin/supervisord -c /etc/supervisord.conf
