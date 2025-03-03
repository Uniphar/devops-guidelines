# Tokens for Consuming Web APIs

To interact with a Web API securely, you need to acquire an access token.

1. [Acquiring Tokens for Web API](#acquiring-tokens-for-web-api)
2. [Understanding Tokens](#understanding-tokens)
3. [Contact](#contact)

&nbsp;

## Acquiring Tokens for Web API

Below are the steps to acquire a token using both `curl` and PowerShell.

### Using `curl`

1. Open your terminal.
2. Execute the following command, replacing the following with your actual values:
   1. `TENANT_ID`
   2. `NEW_APP_CLIENT_ID`
   3. `NEW_APP_CLIENT_SECRET`
   4. `TARGET_SCOPE`
3. The response will contain the access token.

```sh
# Acquiring tokens using CIAM Endpoint
curl -X POST https://TENANT_ID.ciamlogin.com/TENANT_ID/oauth2/v2.0/token \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials&client_id=NEW_APP_CLIENT_ID&client_secret=NEW_APP_CLIENT_SECRET&scope=TARGET_SCOPE"


# Acquiring tokens using Standard EntraID Endpoint
curl -X POST https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials&client_id=NEW_APP_CLIENT_ID&client_secret=NEW_APP_CLIENT_SECRET&scope=TARGET_SCOPE"
```

### Using PowerShell

1. Open your PowerShell terminal.
2. Define the necessary variables.
3. Create the request body.
4. Send the request and retrieve the token.
5. The `$response.access_token` will contain the access token.

```ps1
$tenantId = "TENANT_ID"
$clientId = "NEW_APP_CLIENT_ID"
$clientSecret = "NEW_APP_CLIENT_SECRET"
$scope = "TARGET_SCOPE"

$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = $scope
}

# CIAM Token Endpoint
$uri = "https://$tenantId.ciamlogin.com/$tenantId/oauth2/v2.0/token"

# Standard EntraID Token Endpoint
# $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

$response = Invoke-RestMethod `
                -Method Post `
                -Uri $uri `
                -ContentType "application/x-www-form-urlencoded" `
                -Body $body

$response.access_token
```

&nbsp;

## Understanding Tokens

### `grant_type`

The `grant_type` parameter in the token request specifies
the type of OAuth 2.0 flow being used.
In the context of acquiring a token for a Web API using client credentials,
the `grant_type` is set to `client_credentials`.
This flow is used when the application itself is the resource owner
and needs to access resources directly, without user interaction.

### Token Expiry

Access tokens are typically short-lived for security reasons.
The expiry time of a token is specified in the token response
and is usually given in seconds.
For example, if the token response includes `"expires_in": 3600`,
it means the token is valid for 3600 seconds (1 hour) from the time it was issued.
After the token expires, the application must request a new token
to continue accessing the protected resources.

### The Token

An access token is a string that represents the authorization granted
to the client application.
It is used by the application to authenticate API requests.
The token is usually a JSON Web Token (JWT), which contains
claims about the user or the application,
such as the issuer, subject, audience, and expiry time.

Here is an example of a JWT structure:

1. **Header**: Contains metadata about the token, (e.g. token type, signing algorithm).
2. **Payload**: Contains the claims, which are statements about the user or the application.
3. **Signature**: Used to verify that the token has not been altered.

#### Example Token Response

When you request a token, the response typically looks like this:

```json
{
    "token_type": "Bearer",
    "expires_in": 3600,
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

- token_type: Indicates the type of token, usually "Bearer".
- expires_in: The number of seconds the token is valid for.
- access_token: The actual token string used to authenticate API requests.

#### Using the Token

Once you have the access token,
you include it in the Authorization header of your API requests:

```sh
curl -X GET https://api.example.com/resource \
     -H "Authorization: Bearer ACCESS_TOKEN"
```

In `PowerShell`:

```ps1
$headers = @{
    Authorization = "Bearer $accessToken"
}

$response = Invoke-RestMethod -Uri "https://api.example.com/resource" -Headers $headers
```

### Scopes

Scopes are a way to limit the access granted by the token.
They define what resources and operations the token holder is allowed to access.
When requesting a token, you specify the desired scopes in the scope parameter.

For example, if you want to access a specific API,
you might request a scope like `api://YOUR_API_ID/.default`.
The API will then check the scopes included in the token
to determine if the request is authorized.

#### Example Scopes

- *User.Read*: Allows reading the profile of the signed-in user.
- *Mail.Send*: Allows sending mail as the signed-in user.
- *api://YOUR_API_ID/.default*: default permissions for the specified API access.

#### Example Token Request with Scopes

Using `curl`:

```sh
# Acquiring tokens using CIAM Endpoint
curl -X POST https://TENANT_ID.ciamlogin.com/TENANT_ID/oauth2/v2.0/token \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=client_credentials&client_id=NEW_APP_CLIENT_ID&client_secret=NEW_APP_CLIENT_SECRET&scope=api://YOUR_API_ID/.default"

# Acquiring tokens using Standard EntraID Endpoint
curl -X POST https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=client_credentials&client_id=NEW_APP_CLIENT_ID&client_secret=NEW_APP_CLIENT_SECRET&scope=api://YOUR_API_ID/.default"
```

Using `PowerShell`

```ps1
$tenantId = "TENANT_ID"
$clientId = "NEW_APP_CLIENT_ID"
$clientSecret = "NEW_APP_CLIENT_SECRET"
$scope = "api://YOUR_API_ID/.default"

$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = $scope
}

# CIAM Token Endpoint
$uri = "https://$tenantId.ciamlogin.com/$tenantId/oauth2/v2.0/token"

# Standard EntraID Token Endpoint
# $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

$response = Invoke-RestMethod `
                -Method Post `
                -Uri $uri `
                -ContentType "application/x-www-form-urlencoded" `
                -Body $body

$response.access_token
```

&nbsp;

## Contact

For further assistance, please contact the DevOps Team. They can help with the following:

- Setting up API and/or API client applications and managing secrets.
- Configuring and providing the necessary API scopes.
- Supplying environment-specific Tenant IDs.

&nbsp;
&nbsp;

By understanding these concepts,
developers can effectively manage authentication
and authorization when interacting with Web APIs.
