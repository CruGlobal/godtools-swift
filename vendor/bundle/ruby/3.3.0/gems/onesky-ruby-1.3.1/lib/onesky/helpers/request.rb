require 'rest-client'

module Helpers
  module Request

    ENDPOINT = 'https://platform.api.onesky.io'
    VERSION = 1

    protected

    def get(path, params = {})
      uri = uri_prefix + path
      params = {
        content_type: :json,
        params: auth_hash.merge(params),
      }.merge(custom_header)

      RestClient.get(uri, params) do |resp, req, result|
        handle_error(resp)
      end
    end

    def post(path, body_hash)
      uri = uri_prefix + path
      params = {
        content_type: :json,
        params: auth_hash,
      }.merge(custom_header)

      RestClient.post(uri, body_hash.to_json, params) do |resp, req, result|
        handle_error(resp)
      end
    end

    def post_multipart(path, body_hash)
      uri = uri_prefix + path
      params = {params: auth_hash}.merge(custom_header)

      RestClient.post(uri, body_hash.merge({multipart: true}), params) do |resp, req, result|
        handle_error(resp)
      end
    end

    def put(path, body_hash)
      uri = uri_prefix + path
      params = {
        content_type: :json,
        params: auth_hash,
      }.merge(custom_header)

      RestClient.put(uri, body_hash.to_json, params) do |resp, req, result|
        handle_error(resp)
      end
    end

    def delete(path, params = {})
      uri = uri_prefix + path
      params = {
        content_type: :json,
        params: auth_hash.merge(params)
      }.merge(custom_header)

      RestClient.delete(uri, params) do |resp, req, result|
        handle_error(resp)
      end
    end

    private

    def uri_prefix
      "#{ENDPOINT}/#{VERSION}"
    end

    def handle_error(response)
      return response if response.code.to_i < 400 # return if not error

      case response.code.to_i
      when 400
        raise Onesky::Errors::BadRequestError.new(response), "400 Bad Request - #{extract_message(response)}"
      when 401
        raise Onesky::Errors::UnauthorizedError.new(response), "401 Unauthorized - #{extract_message(response)}"
      when 403
        raise Onesky::Errors::ForbiddenError.new(response), "403 Forbidden - #{extract_message(response)}"
      when 404
        raise Onesky::Errors::NotFoundError.new(response), "404 Not Found - #{extract_message(response)}"
      when 405
        raise Onesky::Errors::MethodNotAllowedError.new(response), "405 Method Not Allowed - #{extract_message(response)}"
      when 500
        raise Onesky::Errors::InternalServerError.new(response), "500 Internal Server Error - Please contact OneSky at support@oneskyapp.com"
      else
        raise Onesky::Errors::OneskyError.new(response), "#{response.code} Error"
      end
    end

    def extract_message(response)
      response_body = JSON.parse(response)
      if response_body.has_key?('meta') && response_body['meta'].has_key?('message')
        return response_body['meta']['message']
      end
      ''
    end

    def custom_header
      {'Onesky-Plugin' => @plugin_code}
    end

  end
end
