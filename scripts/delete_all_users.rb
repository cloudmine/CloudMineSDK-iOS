#
# Requires you to run 'gem install httparty'
#
require 'net/http'
require 'uri'
require 'json'

def main
  domain = ARGV[0]
  appId = ARGV[1]
  masterKey = ARGV[2]
  delete_data = ARGV[3] ? ARGV[3] == "true" : false

  usage() and return if not domain or not appId or not masterKey

  url = "#{domain}v1/app/" + appId.to_s
  accountUrl = url + "/account"
  
  response = cm_get(accountUrl, masterKey)
  puts "response: #{response}"

  
  response["success"].each_key do |user|
    
    delete = cm_delete(accountUrl + "/" + user, masterKey)
    delete_data = cm_delete(url + "/user/" + user + "/data?all=true", masterKey)
    puts "Data? #{delete_data}"
    puts "Deleted user: #{user}"
  end


  if delete_data
    data = cm_delete(url + "/data?all=true" , masterKey)
    puts "Deleted all app data. #{data}"
  end

end

def cm_get(urlString, masterKey)
  url = URI.parse(urlString)
  req = Net::HTTP::Get.new(url.to_s)
  req.add_field("X-CloudMine-ApiKey", masterKey)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = urlString.include? "https"
  res = http.request(req)
  JSON.parse(res.body)
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
