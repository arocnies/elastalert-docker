FROM python:2

# These values you will likely leave alone.
# -----------------------------------------
# Elastalert home directory full path.
ENV ELASTALERT_HOME /opt/elastalert
RUN mkdir -p ${ELASTALERT_HOME}
# Directory holding configuration for Elastalert and Supervisor.
ENV CONFIG_DIR ${ELASTALERT_HOME}/config
# Directory to which Elastalert and Supervisor logs are written.
ENV LOG_DIR ${ELASTALERT_HOME}/logs
# Supervisor configuration file for Elastalert.
ENV ELASTALERT_SUPERVISOR_CONF ${CONFIG_DIR}/elastalert_supervisord.conf
# ElastAlert user for the container
ENV ELASTALERT_USER elastalert

# These variables should match your elastalert config.
# ----------------------------------------------------
# Alias, DNS or IP of Elasticsearch host to be queried by Elastalert. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_HOST logging-es
# Port on above Elasticsearch host. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_PORT 9200
# Path to Elasticsearch cert. This value must match the elastalert config file.
ENV ELASTICSEARCH_CERT /etc/elasticsearch/admin-cert
# Path to Elasticsearch key. This value must match the elastalert config file.
ENV ELASTICSEARCH_KEY /etc/elasticsearch/admin-key
# Elastalert rules directory. This value must match the elastalert config file.
ENV RULES_DIRECTORY ${ELASTALERT_HOME}/rules

# You may want to customize these values for your deployment.
# ----------------------------------------------------------
# Elastalert configuration file path in configuration directory.
ENV ELASTALERT_CONFIG ${CONFIG_DIR}/elastalert.yaml
# ElastAlert writeback index
ENV ELASTALERT_INDEX elastalert_status

# Installation.
# -------------
# Copy the script used to launch the Elastalert when a container is started.
COPY ./start-elastalert.sh /opt/
# Copy supervisord conf
COPY ./supervisord.conf ${ELASTALERT_SUPERVISOR_CONF}

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
