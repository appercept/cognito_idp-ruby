# frozen_string_literal: true

module CognitoIdp
  class Error < StandardError
    attr_reader :error, :error_description, :http_status

    def initialize(error:, error_description: nil, http_status: nil)
      @error = error
      @error_description = error_description
      @http_status = http_status
      super(build_message)
    end

    private

    def build_message
      return error if error_description.nil?

      "#{error}: #{error_description}"
    end
  end
end
