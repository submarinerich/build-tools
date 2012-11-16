#!/usr/bin/env python

import sys,os
from fabric.api import local,settings,abort,run

server = os.environ['DEPLOYMENT_SERVER']
username = os.environ['DEPLOYMENT_USER']

def noEmpties( v ):
	v1 = list()
	for i in v:
		if len(i) > 0:
			v1.append(i)
	return v1

def stop(runClass):
	with settings(host_string=server,user=username):
		process = run("ps -ef | grep %s | grep java"%runClass)
		v = noEmpties(process.split(' '))
		if( len(v) > 10 ):
			psNumber = v[1]
			run("kill %s"%psNumber)
			
def start(runClass,programName):
	with settings(host_string=server,user=username):
		items = run("ls %s*"%programName)
		jars = noEmpties(items.split(' '))
		relevantJar = jars[len(jars)-1]
		run("nohup java -jar %s %s >& /dev/null < /dev/null &"%(relevantJar,runClass),pty=False)

def main():
	pass

if __name__ == '__main__':
	main()