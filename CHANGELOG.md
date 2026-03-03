
<a name="1.0.0"></a>
## [1.0.0](https://github.com/appercept/cognito_idp-ruby/compare/v0.2.0...1.0.0)

> 2026-03-03

### Feat

* Add token revocation support
* Add Token#expired? convenience method

### Fix

* Correct logout_uri test calling wrong method
* Tighten UserInfo and attr mutability
* Redact secrets and tokens from #inspect
* Use standard Base64 encoding for Basic Auth (RFC 7617)
* Raise Error on non-2xx responses

### BREAKING CHANGE


Methods now raise CognitoIdp::Error instead of
returning nil on error responses.


<a name="v0.2.0"></a>
## [v0.2.0](https://github.com/appercept/cognito_idp-ruby/compare/v0.1.1...v0.2.0)

> 2025-11-19

### Feat

* Add CognitoIdp::Token#refresh_token

### Fix

* Add `base64` dependency


<a name="v0.1.1"></a>
## [v0.1.1](https://github.com/appercept/cognito_idp-ruby/compare/v0.1.0...v0.1.1)

> 2023-12-07

### Fix

* UserInfo always responds to missing


<a name="v0.1.0"></a>
## v0.1.0

> 2023-12-02

