# frozen_string_literal: true

module Aws
  module Stubbing
    module Protocols
      class RpcV2

        def stub_data(api, operation, data)
          resp = Seahorse::Client::Http::Response.new
          resp.status_code = 200
          resp.headers['Content-Type'] = content_type(api)
          resp.headers['x-amzn-RequestId'] = 'stubbed-request-id'
          resp.body = build_body(operation, data)
          resp
        end

        def stub_error(error_code)
          http_resp = Seahorse::Client::Http::Response.new
          http_resp.status_code = 400
          http_resp.body = <<-JSON.strip
{
  "code": #{error_code.inspect},
  "message": "stubbed-response-error-message"
}
          JSON
          http_resp
        end

        private

        def content_type(api)
          'application/cbor'
        end

        def build_body(operation, data)
          Aws::RpcV2::Builder.new(operation.output).serialize(data)
        end
      end
    end
  end
end
