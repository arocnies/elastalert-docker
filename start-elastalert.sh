#!/bin/sh

set -e

retryLimit=60

# Wait until Elasticsearch is online since otherwise Elastalert will fail.
while ! curl -XGET -k "https://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/" --cert /etc/elasticsearch/admin-cert --key /etc/elasticsearch/admin-key 2>/dev/null
do
	echo "Waiting for Elasticsearch ${retryLimit}..."
	sleep 1

	# Fail if no connection after the retry limit.
	(( retryLimit -= 1 ))
	if (( $retryLimit == 0 )) ; then
	    echo "Retry limit reached. Could not connect to ElasticSearch."
	    exit -1
	fi
done
sleep 5

# Check if the Elastalert index exists in Elasticsearch and create it if it does not.
if ! curl -XGET -k "https://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/elastalert_status" --cert ${ELASTICSEARCH_CERT} --key ${ELASTICSEARCH_KEY} 2>/dev/null
then
	echo "\nCreating Elastalert index in Elasticsearch..."
    elastalert-create-index --config ${ELASTALERT_CONFIG} --index elastalert_status --old-index ""
else
    echo "\nElastalert index already exists in Elasticsearch."
fi

echo "Starting Elastalert..."
exec supervisord -c ${ELASTALERT_SUPERVISOR_CONF} -n
