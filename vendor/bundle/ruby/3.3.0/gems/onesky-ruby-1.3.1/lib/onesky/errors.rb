module Onesky
  module Errors

    class OneskyError < StandardError
      attr_accessor :response
      def initialize(resp)
        @response = resp
      end
    end

    # Raise error of 400 Bad Request
    class BadRequestError       < OneskyError; end

    # Raise error of 401 Unauthorized
    class UnauthorizedError     < OneskyError; end

    # Raise error of 403 Forbidden
    class ForbiddenError        < OneskyError; end

    # Raise error of 404 Not Found
    class NotFoundError         < OneskyError; end

    # Raise error of 405 Method Not Allowed
    class MethodNotAllowedError < OneskyError; end

    # Raise error of 500 Internal Server Error
    class InternalServerError   < OneskyError; end

  end
end
