defmodule Tunez.Accounts.User.Senders.SendPasswordResetEmail do
  @moduledoc """
  Sends a password reset email
  """

  use AshAuthentication.Sender
  use TunezWeb, :verified_routes

  import Swoosh.Email

  alias Tunez.Mailer

  @impl true
  def send(user, token, _) do
    new()
    # TODO: replace with your email
    |> from({"noreply", "noreply@example.com"})
    |> to(to_string(user.email))
    |> subject("Reset your password")
    |> html_body(body(token: token))
    |> Mailer.deliver!()
  end

  defp body(params) do
    """
    Click this link to reset your password:

    #{url(~p"/password-reset/#{params[:token]}")}
    """
  end
end
