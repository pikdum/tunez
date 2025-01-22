defmodule Tunez.Accounts.User do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Accounts,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication],
    data_layer: AshPostgres.DataLayer

  authentication do
    tokens do
      enabled? true
      token_resource Tunez.Accounts.Token
      signing_secret Tunez.Secrets
      store_all_tokens? true
    end
  end

  postgres do
    table "users"
    repo Tunez.Repo
  end

  actions do
    defaults [:read]

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      forbid_if always()
    end
  end

  attributes do
    uuid_v7_primary_key :id
  end
end
