FROM elasticsearch:5.6.10

LABEL description="This is elasticsearch with authenticated permissions"

COPY readonlyrest-1.18.4_es5.6.10.zip /plugins/readonlyrest-1.18.4_es5.6.10.zip

RUN sh -c 'echo -e "y" | /usr/share/elasticsearch/bin/elasticsearch-plugin install file:///plugins/readonlyrest-1.18.4_es5.6.10.zip'

COPY readonlyrest.yml /usr/share/elasticsearch/config/readonlyrest.yml