## Monster (ELK + carbon + graphite-api + grafana)
FROM qnib/logstash:trunk
MAINTAINER "Christian Kniep <christian@qnib.org>"

ADD etc/yum.repos.d/elasticsearch.repo /etc/yum.repos.d/
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch && \
    yum install -y which zeromq elasticsearch
## Makes no sense to be done while building
#RUN sed -i "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml
ADD etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/
ADD etc/supervisord.d/elasticsearch.ini /etc/supervisord.d/elasticsearch.ini
# diamond collector
ADD etc/diamond/collectors/ElasticSearchCollector.conf /etc/diamond/collectors/ElasticSearchCollector.conf 

## nginx
RUN yum install -y nginx httpd-tools
ADD etc/nginx/ /etc/nginx/
ADD etc/diamond/collectors/NginxCollector.conf /etc/diamond/collectors/NginxCollector.conf

# Add QNIBInc repo
# statsd
RUN yum install -y qnib-statsd qnib-grok-patterns 

## Kibana3
ENV KIBANA_VER 3.1.2
WORKDIR /var/www/
RUN curl -s -o /tmp/kibana-${KIBANA_VER}.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VER}.tar.gz && \
    tar xf /tmp/kibana-${KIBANA_VER}.tar.gz && rm -f /tmp/kibana-${KIBANA_VER}.tar.gz && \
    mv kibana-${KIBANA_VER} kibana
ADD etc/nginx/conf.d/kibana.conf /etc/nginx/conf.d/kibana.conf
WORKDIR /etc/nginx/
# Config kibana-Dashboards
ADD var/www/kibana/app/dashboards/ /var/www/kibana/app/dashboards/
ADD var/www/kibana/config.js /var/www/kibana/config.js

## Kibana4
WORKDIR /opt/
ENV KIBANA_VER 4.0.2
RUN curl -s -L -o kibana-${KIBANA_VER}-linux-x64.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VER}-linux-x64.tar.gz && \
    tar xf kibana-${KIBANA_VER}-linux-x64.tar.gz && \
    rm /opt/kibana*.tar.gz
RUN ln -sf /opt/kibana-${KIBANA_VER}-linux-x64 /opt/kibana
ADD etc/supervisord.d/kibana.ini /etc/supervisord.d/
ADD etc/consul.d/check_kibana4.json /etc/consul.d/
# Config kibana4
ADD opt/kibana/config/kibana.yml /opt/kibana/config/kibana.yml


# logstash config
ADD etc/default/logstash/ /etc/default/logstash/

ADD etc/consul.d/ /etc/consul.d/
#
# Should move to terminal
ADD opt/qnib/bin/ /opt/qnib/bin/

### CARBON
VOLUME "/var/lib/carbon/whisper/"
# carbon
RUN yum install -y python-carbon && \
    mkdir -p /var/lib/carbon/{whisper,lists} && \
    chown carbon -R /var/lib/carbon/whisper/ && \
    rm -f /etc/carbon/* && \
    touch /etc/carbon/aggregation-rules.conf && \
    touch /etc/carbon/storage-aggregation.conf
ADD etc/supervisord.d/ /etc/supervisord.d/
ADD etc/consul.d/check_r0.json /etc/consul.d/
## Carbon config
ADD etc/carbon/ /etc/carbon/

###### pure graphite-api
RUN yum install -y libffi-devel cairo python-gunicorn nginx && \
    pip install --upgrade pip && \
    pip install graphite-api && \
    mkdir -p /var/lib/graphite 
ADD etc/graphite-api.yaml /etc/graphite-api.yaml

## Diamond
ADD etc/diamond/collectors/NginxCollector.conf /etc/diamond/collectors/NginxCollector.conf

# gunicorn nginx
ADD etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD etc/nginx/conf.d/graphite-api.conf /etc/nginx/conf.d/
ADD etc/supervisord.d/graphite-api.ini /etc/supervisord.d/graphite-api.ini
