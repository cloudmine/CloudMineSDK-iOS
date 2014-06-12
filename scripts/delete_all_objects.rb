require 'net/http'
require 'uri'
require 'json'

def main
  appId = ARGV[0]
  masterKey = ARGV[1]
  delete_data = ARGV[2] ? ARGV[2] == "true" : false

  usage() and return if not appId or not masterKey

  url = "https://api.cloudmine.me/v1/app/" + appId.to_s + "/data?all=true"
  
  if delete_data
    response = cm_delete(url, masterKey)
    puts "response: #{response}"
  end
end

def cm_delete(urlString, masterKey)
  url = URI.parse(urlString)
  req = Net::HTTP::Delete.new(url.to_s)
  req.add_field("X-CloudMine-ApiKey", masterKey)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  res = http.request(req)
  unless res.body.strip.empty? then JSON.parse(res.body) else "" end
end

def usage
  puts "usage: 'ruby delete_all_users.rb appid masterkey [delete_app_data[true/false]'"
  true
end

main
