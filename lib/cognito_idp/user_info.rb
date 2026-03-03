# frozen_string_literal: true

require "ostruct"

module CognitoIdp
  class UserInfo
    def initialize(attributes)
      @attributes = OpenStruct.new(attributes)
    end

    def method_missing(method, ...)
      attribute = @attributes.send(method, ...)
      attribute.is_a?(Hash) ? OpenStruct.new(attribute) : attribute
    end

    def respond_to_missing?(method, include_private = false)
      @attributes.respond_to?(method, include_private) || super
    end
  end
end
