#!/usr/bin/env bash

HOST=http://localhost:9999
CONTEXT=bigdata

while getopts h:c:n:o:p:l:s option
do
  case "${option}"
  in
    h) HOST=${OPTARG};;
    c) CONTEXT=${OPTARG};;
    n) NAMESPACE=${OPTARG};;
    o) PROXYHOST=${OPTARG};;
    p) PROXYPORT=${OPTARG};;  
    l) LANGS=${OPTARG};;
    s) SKIPSITE=1;;
  esac
done

# allow extra args
shift $((OPTIND-1))

if [ -z "$NAMESPACE" ]
then
  echo "Usage: $0 -n <namespace> [-h <host>] [-c <context>]"
  exit 1
fi

if [ -z "$LANGS" ]; then
    ARGS=
else
    ARGS="--labelLanguage $LANGS --singleLabel $LANGS"
fi

if [ ! -z "$SKIPSITE" ]; then
    ARGS="$ARGS --skipSiteLinks"
fi

LOG=""
if [ -f /etc/wdqs/updater-logs.xml ]; then
    LOG="-Dlogback.configurationFile=/etc/wdqs/updater-logs.xml"
fi
if [ -f updater-logs.xml ]; then
    LOG="-Dlogback.configurationFile=updater-logs.xml"
fi

JVMARGS=

if [ ! -z "$PROXYHOST" ]; then
    JVMARGS="$JVMARGS -Dhttps.proxyHost=$PROXYHOST"
fi

if [ ! -z "$PROXYPORT" ]; then
    JVMARGS="$JVMARGS -Dhttps.proxyPort=$PROXYPORT"
fi

CP=lib/wikidata-query-tools-*-jar-with-dependencies.jar
MAIN=org.wikidata.query.rdf.tool.Update
SPARQL_URL=$HOST/$CONTEXT/namespace/$NAMESPACE/sparql
AGENT=-javaagent:lib/jolokia-jvm-1.3.1-agent.jar=port=8778,host=localhost
echo "Updating via $SPARQL_URL"
java -Xmx2g $JVMARGS -cp $CP $LOG $AGENT $MAIN $ARGS --sparqlUrl $SPARQL_URL "$@"
