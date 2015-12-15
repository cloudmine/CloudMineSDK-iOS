require 'net/http'
require 'uri'
require 'json'

def main
  domain = ARGV[0]
  appId = ARGV[1]
  masterKey = ARGV[2]
  delete_data = ARGV[3] ? ARGV[3] == "true" : false

  usage() and return if not domain or not appId or not masterKey

  url = "#{domain}v1/app/" + appId.to_s + "/data?all=true"
  puts "URL #{url}"
  
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
  http.use_ssl = urlString.include? "https"
  res = http.request(req)
  unless res.body.strip.empty? then JSON.parse(res.body) else "" end
end

def usage
  puts "usage: 'ruby delete_all_users.rb domain appid masterkey [delete_app_data[true/false]'"
  true
end

main
