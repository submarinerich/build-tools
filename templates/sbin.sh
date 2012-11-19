#!/bin/sh

JAR_LOCATION="{$JARLOCATION}"

SCRIPT="nohup java -jar $JAR_LOCATION {$RUNNER} >& /dev/null < /dev/null &"

${SCRIPT}
