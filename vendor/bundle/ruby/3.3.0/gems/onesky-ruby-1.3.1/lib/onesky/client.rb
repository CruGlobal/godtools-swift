require 'digest'

require 'onesky/resources/locale'
require 'onesky/resources/project_type'
require 'onesky/resources/project_group'
require 'onesky/resources/project'
require 'onesky/helpers/request'
require 'onesky/project'

module Onesky
  class Client
    include Resources::Locale
    include Resources::ProjectType
    include Resources::ProjectGroup
    include Resources::Project
    include Helpers::Request

    attr_accessor :api_key, :api_secret, :project_id, :plugin_code

    def initialize(key, secret)
      @api_key = key
      @api_secret = secret

      # Plugin code for custom header
      @plugin_code = 'ruby-wrapper'
    end

    def auth_hash
      now = Time.now.to_i

      {
        api_key: @api_key,
        timestamp: now,
        dev_hash: Digest::MD5.hexdigest(now.to_s + @api_secret)
      }
    end

  end
end
