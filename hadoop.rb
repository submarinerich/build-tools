



desc "put a file in hadoop"
task :put, :arg1 do | t,arg |
  sh "hadoop-bin hadoop fs -put "+arg.arg1+" /"
end
desc "remove a file in hadoop"
task :rm, :arg1 do | t,arg |
  sh "hadoop-bin hadoop fs -rm /"+arg.arg1
end

desc "list the files currently in hadoop"
task :ls do
  sh "hadoop-bin hadoop fs -ls /"
end


