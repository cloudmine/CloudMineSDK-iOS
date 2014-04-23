#
# Requires you to run 'gem install httparty'
#
require 'httparty'

def main
  appId = ARGV[0]
  masterKey = ARGV[1]
  delete_data = ARGV[2] ? ARGV[2] == "true" : false

  usage() and return if not appId or not masterKey

  url = "https://api.cloudmine.me/v1/app/" + appId.to_s
  accountUrl = url + "/account"
  
  response = HTTParty.get(accountUrl, :headers => {"X-CloudMine-ApiKey" => masterKey})
  
  puts "response: #{response}"

  response["success"].each_key do |user|
    delete = HTTParty.delete(accountUrl + "/" + user, :headers => {"X-CloudMine-ApiKey" => masterKey})
    delete_data = HTTParty.delete(url + "/user/" + user + "/data?all=true" + user, :headers => {"X-CloudMine-ApiKey" => masterKey})

    puts "Data? #{delete_data}"

#/user/data

    puts "Deleted user: #{user}"

  end


  if delete_data
    data = HTTParty.delete(url + "/data?all=true", :headers => {"X-CloudMine-ApiKey" => masterKey})
    puts "Deleted all app data. #{data}"
  end

end

def usage
  puts "usage: 'ruby delete_all_users.rb appid masterkey [delete_app_data[true/false]'"
  true
end


main
