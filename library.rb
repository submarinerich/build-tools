
require 'build/maven.rb'

desc "publish release version"
task :publish => [:clean] do
  Rake::Task['package'].invoke
  pi = projectInfo()
  artifactId = pi[2]
  groupId = pi[3]
  version = pi[0]
  scalaVersion = pi[1]
  jarname = artifactId+"_"+scalaVersion+"-"+version+".jar"
  pomname = artifactId+"_"+scalaVersion+"-"+version+".pom"
  sh "mkdir deployment"
  sh "cat example.pom | sed 's/$CURRENTVERSION/"+version+"/' | sed 's/$VERSION/"+version+"/' | sed 's/$SCALAVERSION/"+scalaVersion+"/' > deployment/"+pomname
  serverpath = "/home/ubuntu/maven/com/submarinerich/"+artifactId+"_"+scalaVersion+"/"+version+"/"
  sh "cp target/"+artifactId+"-"+version+".jar deployment/"+jarname
  sh "ssh -i ~/.ec2/ftv.pem ubuntu@submarinerich.com mkdir -p "+serverpath
  sh "scp -i ~/.ec2/ftv.pem deployment/* ubuntu@submarinerich.com:"+serverpath
  puts "<dependency>"
  puts "  <groupId>com.submarinerich</groupId>"
  puts "  <artifactId>"+artifactId+"_"+scalaVersion+"</artifactId>"
  puts "  <version>"+version+"</version>"
  puts "</dependency>"
  sh "git tag -a v"+version+" -m 'version "+version+"'"
  sh "git push --tags"
end

require 'date'
require 'time'
desc "publish oneoff to the server"
task :publishoneoff => [ :package ] do
  Rake::Task['clean'].invoke
  pi = projectInfo()
  artifactId = pi[2]
  groupId = pi[3]
  version = pi[0]
  scalaVersion = pi[1]
  d = Time.new
  timestring = d.strftime("%Y%m%d%H%M%S")
  sh "mkdir deployment"
  jarname = artifactId+"_"+scalaVersion+"-"+version+"."+timestring+".jar"
  pomname = artifactId+"_"+scalaVersion+"-"+version+"."+timestring+".pom"
  minor = version+"."+timestring
  sh "cat example.pom | sed 's/$VERSION/"+minor+"/' | sed 's/$SCALAVERSION/"+scalaVersion+"/' > deployment/"+pomname
  serverpath = "/home/ubuntu/maven/com/submarinerich/"+artifactId+"_"+scalaVersion+"/"+version+"."+timestring+"/"
  sh "cp target/"+artifactId+"-"+version+".jar deployment/"+jarname
  sh "ssh -i ~/.ec2/ftv.pem ubuntu@submarinerich.com mkdir -p "+serverpath
  sh "scp -i ~/.ec2/ftv.pem deployment/* ubuntu@submarinerich.com:"+serverpath
  puts "<dependency>"
  puts "  <groupId>"+groupId+"</groupId>"
  puts "  <artifactId>"+artifactId+"_"+scalaVersion+"</artifactId>"
  puts "  <version>"+version+"."+timestring+"</version>"
  puts "</dependency>"
end
