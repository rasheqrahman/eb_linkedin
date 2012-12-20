# /Users/<username>/.rvm/rubies/ruby-1.9.3-p194/bin/ruby

require 'rubygems'
require 'linkedin'

# Fill in the keys you received after registering your app
api_key = ''
api_secret = ''

client = LinkedIn::Client.new(api_key, api_secret)
rtoken = client.request_token.token
rsecret = client.request_token.secret

puts client.request_token.authorize_url

puts "Enter the above URL in your browser to manually authorize your application. After logging in you will be given a pin number. Please enter it below:"

pin = gets.chomp

atoken, asecret = client.authorize_from_request(rtoken, rsecret, pin)

puts "Copy (cmd-c) or write down the following codes which will have to be entered as the Linkedin API variables at the top of the file entitled config.yml"
puts "\n"

puts "api_key: " + "'#{api_key}'"
puts "api_secret:  " + "'#{api_secret}'" 
puts "api_token_authorized: " + "'#{atoken}'" 
puts "api_secret_authorized: " + "'#{asecret}'"
