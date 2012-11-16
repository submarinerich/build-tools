
xmlfiles = ["pom.xml","example.pom"]

require 'rubygems'
require 'rexml/document'
require 'build/library.rb'
require 'fileutils'

def version()
  m = projectInfo()
  return m[0]
end

def buildClasspath
  if !File.exist?("classpath.txt")
    sh "mvn dependency:build-classpath"
  end
  classpath = ""
  file = File.new("classpath.txt", "r")
  while (line = file.gets)
    classpath += line
  end
  file.close
  return classpath
end


def projectInfo()
  wholepom = ""
  file = File.new("pom.xml", "r")
  while (line = file.gets)
    wholepom += line
  end
  file.close
  doc = REXML::Document.new(wholepom)
  r = []
  doc.elements.each('project/version') do |ele|
    r.push(ele.text)
  end
  doc.elements.each('project/properties/scala.version') do |ele|
    r.push(ele.text)
  end
  doc.elements.each('project/artifactId') do |ele|
    r.push(ele.text)
  end
  doc.elements.each('project/groupId') do |ele|
    r.push(ele.text)
  end
  doc.elements.each('project/packaging') do |ele|
    r.push(ele.text)
  end
  doc.elements.each("project/properties/runner.classpath") do |ele|
    r.push(ele.text)
  end
  return r 
end


desc "clean everything"
task :clean do
  if File.exist?("classpath.txt")
    FileUtils.rm_r "classpath.txt"
  end
  if File.exist?("target")
    FileUtils.rm_r "target/"
  end
  if File.exist?("deployment")
    FileUtils.rm_r "deployment/"
  end
  if File.exist?("docs")
    FileUtils.rm_r "docs/"
  end
end


desc "package into a jar"
task :package do
  Rake::Task['compile'].invoke
  sh "mvn package"
end

desc "xmllint the pom files"
task :tidy do
  xmlfiles.each do | xml | 
    if File.exists? xml
      sh "xmllint --format "+xml+" > temp.xml"
      sh "mv temp.xml "+xml
    end
  end  
end

desc "run scalatest tests"
task :test do
  sh "mvn test"
end

desc "console!"
task :console do
  sh "mvn scala:console"
end

desc "compile " 
task :compile do
  sh "mvn compile"
end

desc "deploy to dock server"
task :deploy => :package do 
  pi = projectInfo()
  sh "fab -f build/admin.py install:"+pi[2]+","+pi[0]
  report("deployed"+pi[2])
end

