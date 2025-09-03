defmodule CorevoxWeb.Auth.Guardian do
  use Guardian, otp_app: :corevox
  alias Corevox.Accounts

   # Генерация subject для токена (обычно user id)
   def subject_for_token(user, _claims) do
     {:ok, to_string(user.id)}
   end

   # Декодируем subject обратно в user
   def resource_from_claims(%{"sub" => id}) do
     case Accounts.get_user!(id) do
       nil -> {:error, :not_found}
       user -> {:ok, user}
     end
   end

end
