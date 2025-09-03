defmodule Corevox.Cors do
  use Corsica.Router,
    origins: ["http://localhost:4321"],
    allow_methods: ["GET", "POST", "OPTIONS", "PUT", "DELETE", "PATCH", "HEAD", "CONNECT", "TRACE"],
    allow_headers: ["content-type", "authorization"],
    allow_credentials: true,
    max_age: 3600,
    send_preflight_response?: true

  resource "/api/v1/auth/*", allow_methods: ["POST", "OPTIONS"], allow_credentials: false
  resource "/api/v1/*", allow_methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"], allow_credentials: true
end
