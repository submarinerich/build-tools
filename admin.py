#!/usr/bin/env python

import sys,os,time
from fabric.api import local,settings,abort,run,put,sudo

server = os.environ['DEPLOYMENT_SERVER']
username = os.environ['DEPLOYMENT_USER']

def install(programName,version):
	with settings(host_string=server,user=username,warn_only=True):
		relevantJar="%s-%s.one-jar.jar"%(programName,version)
		put("target/%s"%relevantJar,"/home/%s/%s"%(username,relevantJar))
		put("scripts/init.sh","/home/%s/%s-init.sh"%(username,programName))
		put("scripts/sbin.sh","/home/%s/%s-sbin.sh"%(username,programName))
		sudo("mv /home/%s/%s-init.sh /etc/init.d/%s"%(username,programName,programName))
		sudo("mv /home/%s/%s-sbin.sh /usr/sbin/%s"%(username,programName,programName))
		sudo("mv %s /usr/share/sr/%s.jar"%(relevantJar,programName))
		sudo("chmod 755 /usr/share/sr/%s.jar"%(programName))
		sudo("chmod 755 /etc/init.d/%s"%(programName))
		sudo("chmod 755 /usr/sbin/%s"%(programName))
		sudo("/etc/init.d/%s stop"%programName,pty=False)
		time.sleep(2)
		sudo("/etc/init.d/%s start"%programName,pty=False)
		

def main():
	pass

if __name__ == '__main__':
	main()