
require 'rubygems'
require 'date'
require 'time'
require 'fileutils'

desc "create new db file to append"
task :newsql do
  puts "creating new sql file with the date stamp"
  d = Time.new
  timestring = d.strftime("%Y%m%d%H%M%S")
  filename = "db/"+timestring+"_dbupdate.sql"
  File.open(filename,File::RDWR|File::CREAT,0755){ |f|
    f.rewind
    f.write("-- update to the db file\n")
    f.write("-- filename: "+filename+"\n\n")
    f.close
  }
end

desc "init database with only the bootstrap.sql"
task :initdb do
  report("humanweatherinitdb")
  sh "psql -h localhost -U postgres --file db/bootstrap.sql"
end


desc "update the database with everything since bootstrap"
task :updatedb do
  Dir.foreach("db"){ | x |
    if x.include? "dbupdate.sql" and !x.include? ".swp"
      puts "sh psql -h localhost -U postgres --file "+x
    end
  }
end

desc "fully reset the db to where it should be and delete everything"
task :resetdb => :initdb do
  Rake::Task['updatedb'].invoke
  puts "database reset"
end


