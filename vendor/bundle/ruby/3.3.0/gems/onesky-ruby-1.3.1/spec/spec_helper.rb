require 'digest'
require 'onesky'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

def auth_query_string(api_key, api_secret)
  now = Time.now.to_i
  output = '?'
  output += "api_key=#{api_key}"
  output += "&timestamp=#{now.to_s}"
  output += "&dev_hash=#{Digest::MD5.hexdigest(now.to_s + api_secret)}"

  output
end

def full_path_with_auth_hash(path, api_key, api_secret)
  "#{Helpers::Request::ENDPOINT}/#{Helpers::Request::VERSION}#{path}#{auth_query_string(api_key, api_secret)}"
end
