
require 'net/http'

def report(tagname)
  Net::HTTP.get('www.candersonmiller.com','/analytics/count/t:'+tagname)
end
