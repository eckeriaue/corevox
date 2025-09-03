defmodule Corevox.Cors do
  use Corsica.Router,
    origins: ["http://localhost:4321"],
    allow_credentials: true,
    max_age: 600,
    log: [rejected: :error, invalid: :warn, accepted: :debug]

  resource "/api/v1/auth/*", allow_methods: ["POST", "OPTIONS"]
  resource "/api/v1/*", allow_methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
end
