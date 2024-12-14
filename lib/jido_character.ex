defmodule JidoCharacter do
  # @moduledoc """
  # Core schema and public API for the JidoCharacter system.
  # Provides the main character schema and delegates operations to Core.
  # """

  use TypedEctoSchema
  import Ecto.Changeset
  import JidoCharacter.Helpers

  alias JidoCharacter.Identity
  alias JidoCharacter.Personality

  @type character :: t()
  @type changeset :: Ecto.Changeset.t()
  @type error :: {:error, changeset()} | {:error, term()}

  @derive Inspect
  @derive Jason.Encoder
  @primary_key false
  typed_embedded_schema do
    field(:id, :string)
    field(:name, :string)
    field(:description, :string)

    embeds_one(:identity, Identity, on_replace: :update)
    embeds_one(:personality, Personality, on_replace: :update)
    # embeds_one(:cognitive, Cognitive, on_replace: :update)
    # embeds_one(:evolution, Evolution, on_replace: :update)
    # embeds_one(:world, World, on_replace: :update)
    # embeds_one(:config, Config, on_replace: :update)
    # embeds_one(:economic, Economic, on_replace: :update)
    # embeds_one(:identity_system, IdentitySystem, on_replace: :update)

    field(:created_at, :utc_datetime_usec)
    field(:updated_at, :utc_datetime_usec)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:id, :name, :description, :created_at, :updated_at])
    |> cast_embed(:identity, with: &Identity.changeset/2)
    |> validate_required([:id])
    |> validate_length(:name, max: 256)
    |> ensure_field(:identity, &Identity.template/0)
  end

  @doc """
  Creates a new blank character struct with default values.
  This is used internally and shouldn't be used directly - use JidoCharacter.new/1 instead.
  """
  def template(attrs \\ %{}) do
    now = DateTime.utc_now()

    base = %__MODULE__{
      id: nil,
      name: nil,
      description: nil,
      created_at: now,
      updated_at: now,
      identity: Identity.template(),
      personality: Personality.template()
      # cognitive: Cognitive.template(),
      # evolution: Evolution.template(),
      # world: World.template(),
      # config: Config.template(),
      # economic: Economic.template(),
      # identity_system: IdentitySystem.template()
    }

    struct(base, attrs)
  end

  # Public API delegates
  defdelegate new(id \\ nil), to: JidoCharacter.Core
  defdelegate get(id), to: JidoCharacter.Core
  defdelegate update(character, attrs), to: JidoCharacter.Core
  defdelegate delete(id), to: JidoCharacter.Core
  defdelegate clone(character, new_id), to: JidoCharacter.Core
  defdelegate validate(character), to: JidoCharacter.Core
  defdelegate to_json(character), to: JidoCharacter.Core
  defdelegate from_json(json), to: JidoCharacter.Core
  defdelegate persist_adapter(), to: JidoCharacter.Core
  defdelegate compose(character, opts \\ []), to: JidoCharacter.Core
end
