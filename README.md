# Vapor-example
An example web app using Vapor.

The example contains:
-  Login system ( including google and facebook auth)
- Chat via websocket
- Rest Api
- Unit tests

## Requirements

1. Swift 3.0
2. Vapor Toolbox
2. Mysql (linked)
3. Redis

In order to build the app you have to set environment variables for mysql. The redis configuration is optional, unless it doesn't use the default values.

Here are the required environment variables for mysql. These can be found in Config/secrets/mysql.json
```
{
"host": "$MYSQL_HOST",
"user": "$MYSQL_USER",
"password": "$MYSQL_PASSWORD",
"database": "$MYSQL_DATABASE",
"port": "$MYSQL_PORT",
"encoding": "$MYSQL_ENCODING"
}
```
## Building
```
vapor build
```
## Running
```
vapor run serve --name App
```
