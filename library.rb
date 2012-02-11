
require 'build/maven.rb'
require 'rubygems'
require 'fog'
require 'fileutils'

def makeDeploymentDirectory()
  if File.directory?("deployment")
    FileUtils.rm_r "deployment"
  end
  if !File.directory?("deployment")
    Dir.mkdir("deployment")
  end
end

def makePomFromTemplate(scalaVersion,productVersion,pomDestination)
  pomTemplate = ""
  file = File.new("example.pom","r")
  while( line = file.gets )
    pomTemplate += line
  end
  file.close
  pomTemplate.gsub!("$VERSION",productVersion)
  pomTemplate.gsub!("$SCALAVERSION",scalaVersion)
  File.open("deployment/"+pomDestination, File::RDWR|File::CREAT,0755){ | f |
    f.rewind
    f.write(pomTemplate)
    f.close
  }
end

def hashDeploymentFiles()
  Dir.foreach("deployment"){ | x |
    if x.include? ".pom" or x.include?".jar" and !x.include?".sha1" and !x.include?".md5"
      sh "shasum deployment/"+x+" | cut -d ' ' -f 1 > deployment/"+x+".sha1"
      sh "md5 deployment/"+x+" | cut -d ' ' -f 4 > deployment/"+x+".md5"
    end
  }
end



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
  serverpath = "/home/ubuntu/maven/com/submarinerich/"+artifactId+"_"+scalaVersion+"/"+version+"/"


  ## Connections

  options = { :keys => "~/.ec2/ftv.pem" }
  sshConnection = Fog::SSH::Real.new("submarinerich.com","ubuntu",options)
  scpConnection = Fog::SCP::Real.new("submarinerich.com","ubuntu",options)


  ## Deployment Work

  makeDeploymentDirectory()
  makePomFromTemplate( scalaVersion, version, pomname )

  FileUtils.cp "target/"+artifactId+"-"+version+".jar", "deployment/"+jarname
  hashDeploymentFiles()
  sshConnection.run(["mkdir -p "+serverpath])
  Dir.foreach("deployment"){ | x |
    if x.include? ".pom" or x.include? ".jar" or x.include?".sha1" or x.include?".md5"
      puts "uploaded : "+x
      scpConnection.upload("deployment/"+x, serverpath )
    end
  }
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

  ## Variables/Naming
  pi = projectInfo()
  artifactId = pi[2]
  groupId = pi[3]
  version = pi[0]
  scalaVersion = pi[1]
  d = Time.new
  timestring = d.strftime("%Y%m%d%H%M%S")
  jarname = artifactId+"_"+scalaVersion+"-"+version+"."+timestring+".jar"
  pomname = artifactId+"_"+scalaVersion+"-"+version+"."+timestring+".pom"
  minor = version+"."+timestring
  product = artifactId+"-"+version+".jar"
  serverpath = "/home/ubuntu/maven/com/submarinerich/"+artifactId+"_"+scalaVersion+"/"+version+"."+timestring+"/"


  ## Server Connections
  options = { :keys => "~/.ec2/ftv.pem" }
  sshConnection = Fog::SSH::Real.new("submarinerich.com","ubuntu",options)
  scpConnection = Fog::SCP::Real.new("submarinerich.com","ubuntu",options)


  ## Deployment Work
  
  makeDeploymentDirectory()
  makePomFromTemplate(scalaVersion,minor,pomname)

  FileUtils.cp "target/"+product, "deployment/"+jarname
  hashDeploymentFiles()
  sshConnection.run(["mkdir -p "+serverpath])
  Dir.foreach("deployment"){ | x |
    if x.include? ".pom" or x.include? ".jar" or x.include?".sha1" or x.include?".md5"
      puts "uploaded : "+x
      scpConnection.upload("deployment/"+x, serverpath )
    end
  }
  puts "<dependency>"
  puts "  <groupId>"+groupId+"</groupId>"
  puts "  <artifactId>"+artifactId+"_"+scalaVersion+"</artifactId>"
  puts "  <version>"+version+"."+timestring+"</version>"
  puts "</dependency>"
end
