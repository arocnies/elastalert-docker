FROM python:2

# Directory holding configuration for Elastalert and Supervisor.
ENV CONFIG_DIR /opt/config
# Elastalert rules directory.
ENV RULES_DIRECTORY /opt/rules
# Elastalert configuration file path in configuration directory.
ENV ELASTALERT_CONFIG ${CONFIG_DIR}/elastalert.yaml
# Directory to which Elastalert and Supervisor logs are written.
ENV LOG_DIR /opt/logs
# Elastalert home directory full path.
ENV ELASTALERT_HOME /opt/elastalert
# Supervisor configuration file for Elastalert.
ENV ELASTALERT_SUPERVISOR_CONF ${CONFIG_DIR}/elastalert_supervisord.conf
# Alias, DNS or IP of Elasticsearch host to be queried by Elastalert. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_HOST elasticsearchhost
# Port on above Elasticsearch host. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_PORT 9200
# Use TLS to connect to Elasticsearch (True or False)
ENV ELASTICSEARCH_TLS False
# Verify TLS
ENV ELASTICSEARCH_TLS_VERIFY False
# ElastAlert writeback index
ENV ELASTALERT_INDEX elastalert_status
# ElastAlert user for the container
ENV ELASTALERT_USER elastalert

# Copy the script used to launch the Elastalert when a container is started.
COPY ./start-elastalert.sh /opt/
# Copy supervisord conf
COPY ./supervisord.conf ${CONFIG_DIR}/elastalert_supervisord.conf

WORKDIR "${ELASTALERT_HOME}"

# Install via pip
RUN pip install elastalert
RUN easy_install supervisor

# Setup non-root user
RUN useradd -ms /bin/bash ${ELASTALERT_USER}
USER ${ELASTALERT_USER}

# Define mount points.
VOLUME [ "${CONFIG_DIR}", "${RULES_DIRECTORY}", "${LOG_DIR}" ]

# Launch Elastalert when a container is started.
CMD ["/opt/start-elastalert.sh"]
