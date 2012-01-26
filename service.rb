
require 'rubygems'
require 'aws/s3'



def upload( file )

  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  )
  AWS::S3::S3Object.store(file, open(file), 'sr-staging')
  return true
end

desc "upload a sample file to s3"
task :upload, :arg1 do | t,arg |
  puts "uploading: "+arg.arg1
  upload( arg.arg1 )
  puts "uploaded: "+arg.arg1
end



require 'date'
require 'time'

def uploadWar( warfile )
  d = Time.new
  timestring = d.strftime("%Y%m%d%H%M%S")
  firstchunk = warfile.split(".war")[0]
  newfilename = firstchunk + "-" + timestring + ".war"
  sh "cp "+warfile+" "+newfilename
  upload(newfilename)
  return newfilename
end

require 'build/maven.rb'

JETTY_WEB="src/main/webapp/WEB-INF/jetty-web.xml"

def modifyJettyEnv(connectionName)
  p = projectInfo()
  version = p[0]
  scalaVersion = [1]
  artifactId = p[2]
  groupId = p[3]
  packaging = p[4]
  productionWar = artifactId+"-"+version+"."+packaging
  toAdd="<Set name=\"war\"><SystemProperty name=\"jetty.home\" default=\".\"/>/webapps/"+productionWar+"</Set><Set name=\"connectorNames\"><Array type=\"String\"><Item>"+connectionName+"</Item></Array></Set></Configure>"
  sh "cp "+JETTY_WEB+" tmp.xml"
  sh "cat tmp.xml | sed \'s#</Configure># #' > "+JETTY_WEB
  File.open(JETTY_WEB, 'a') {|f| f.write(toAdd) }
end

def restoreJettyEnv()
    sh "mv tmp.xml "+JETTY_WEB
end







