#!/bin/sh

JAR_LOCATION="{$JARLOCATION}"

SCRIPT="java -Xms256m -Xmx256m -XX:NewSize=64m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -jar $JAR_LOCATION {$RUNNER}"

${SCRIPT}