# frozen_string_literal: true

require "cognito_idp/version"

module CognitoIdp
  autoload :AuthorizationUri, "cognito_idp/authorization_uri"
  autoload :Client, "cognito_idp/client"
  autoload :LogoutUri, "cognito_idp/logout_uri"
  autoload :Token, "cognito_idp/token"
  autoload :UserInfo, "cognito_idp/user_info"
end
