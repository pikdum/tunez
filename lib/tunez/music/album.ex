defmodule Tunez.Music.Album do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  graphql do
    type :album
  end

  json_api do
    type "album"
  end

  postgres do
    table "albums"
    repo Tunez.Repo

    references do
      reference :artist, on_delete: :delete
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :year_released, :cover_image_url, :artist_id]
    end

    update :update do
      accept [:name, :year_released, :cover_image_url]
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action([:update, :destroy]) do
      authorize_if expr(^actor(:role) == :editor and created_by_id == ^actor(:id))
    end
  end

  preparations do
    prepare build(sort: [year_released: :desc])
  end

  changes do
    change relate_actor(:created_by, allow_nil?: true), on: [:create]
    change relate_actor(:updated_by, allow_nil?: true), on: [:create]
    change relate_actor(:updated_by, allow_nil?: true), on: [:update]
  end

  validations do
    validate numericality(:year_released,
               greater_than: 1950,
               less_than_or_equal_to: &__MODULE__.next_year/0
             ),
             where: [present(:year_released)],
             message: "must be between 1950 and this year"

    validate match(
               :cover_image_url,
               ~r/(^https:\/\/|\/images\/).+(\.png|\.jpg)$/
             ),
             where: [changing(:cover_image_url)],
             message: "must start with https:// or /images/"
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :year_released, :integer do
      allow_nil? false
      public? true
    end

    attribute :cover_image_url, :string do
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  def next_year, do: Date.utc_today().year + 1

  relationships do
    belongs_to :artist, Tunez.Music.Artist do
      allow_nil? false
    end

    belongs_to :created_by, Tunez.Accounts.User
    belongs_to :updated_by, Tunez.Accounts.User
  end

  calculations do
    calculate :years_ago, :integer, expr(2025 - year_released)

    calculate :string_years_ago,
              :string,
              expr("wow, this was released " <> years_ago <> " years ago!")
  end

  identities do
    identity :unique_album_names_per_artist, [:name, :artist_id],
      message: "already exists for this artist"
  end
end
