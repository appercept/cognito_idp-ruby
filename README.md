# CognitoIdp [![Ruby](https://github.com/appercept/cognito_idp-ruby/actions/workflows/main.yml/badge.svg)](https://github.com/appercept/cognito_idp-ruby/actions/workflows/main.yml)

Client for interacting with Amazon Cognito IdP (User Pools) endpoints.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add cognito_idp

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install cognito_idp

## Usage

### Client setup

```ruby
client = CognitoIdp::Client.new(
  client_id: "your_client_id",
  domain: "your-domain.auth.eu-west-1.amazoncognito.com",
  client_secret: "your_client_secret" # optional, depends on app client config
)
```

### Authorization URI

Build a URL to redirect users to the Cognito hosted UI:

```ruby
url = client.authorization_uri(
  redirect_uri: "https://example.com/auth/callback",
  scope: %w[openid email profile],
  state: SecureRandom.hex
)
```

PKCE is supported via `code_challenge` and `code_challenge_method`:

```ruby
url = client.authorization_uri(
  redirect_uri: "https://example.com/auth/callback",
  code_challenge: challenge,
  code_challenge_method: "S256"
)
```

### Exchanging an authorization code for tokens

```ruby
token = client.get_token(
  grant_type: "authorization_code",
  code: params[:code],
  redirect_uri: "https://example.com/auth/callback"
)

token.access_token  # => "eyJra..."
token.id_token      # => "eyJra..."
token.refresh_token # => "eyJjd..."
token.expires_in    # => 3600
token.expired?      # => false
```

With PKCE, pass the `code_verifier`:

```ruby
token = client.get_token(
  grant_type: "authorization_code",
  code: params[:code],
  redirect_uri: "https://example.com/auth/callback",
  code_verifier: stored_verifier
)
```

### Client credentials

```ruby
token = client.get_token(
  grant_type: "client_credentials",
  scope: "https://api.example.com/orders.read"
)
```

### Refreshing tokens

```ruby
token = client.get_token(
  grant_type: "refresh_token",
  refresh_token: token.refresh_token
)
```

### User info

Accepts an access token string or a `Token` object:

```ruby
user_info = client.get_user_info(token)

user_info.sub      # => "248289761001"
user_info.email    # => "janedoe@example.com"
user_info.username # => "j.doe"
```

### Revoking tokens

Revokes a refresh token. Accepts a token string or a `Token` object (which uses its `refresh_token`):

```ruby
client.revoke_token(token)
```

### Logout URI

```ruby
url = client.logout_uri(
  logout_uri: "https://example.com/signed-out",
  redirect_uri: "https://example.com/"
)
```

### Error handling

All API calls raise `CognitoIdp::Error` on non-2xx responses:

```ruby
begin
  client.get_token(grant_type: "authorization_code", code: "expired_code")
rescue CognitoIdp::Error => e
  e.error             # => "invalid_grant"
  e.error_description # => "Authorization code has expired"
  e.http_status       # => 400
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/appercept/cognito_idp-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/appercept/cognito_idp-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CognitoIdp project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/appercept/cognito_idp-ruby/blob/main/CODE_OF_CONDUCT.md).
