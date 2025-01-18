defmodule JidoCharacter do
  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: []}
  @primary_key false
  typed_embedded_schema do
    # Existing JIDO fields
    field(:id, :string)
    embeds_one(:identity, JidoCharacter.Identity, on_replace: :update)
    embeds_one(:personality, JidoCharacter.Personality, on_replace: :update)

    # SoulScript block
    embeds_one(:soulscript, JidoCharacter.SoulScript.Root, on_replace: :update)

    # Cognitive module
    embeds_one(:cognitive, JidoCharacter.Cognitive, on_replace: :update)

    # Evolution module
    embeds_one(:evolution, JidoCharacter.Evolution, on_replace: :update)

    # These will be implemented in future iterations
    # embeds_one :personality_extras, JidoCharacter.PersonalityExtras
    # embeds_one :world, JidoCharacter.World
    # embeds_one :economics, JidoCharacter.Economics
    # embeds_one :identity_system, JidoCharacter.IdentitySystem

    field(:created_at, :utc_datetime_usec)
    field(:updated_at, :utc_datetime_usec)
  end

  def changeset(character \\ %__MODULE__{}, attrs) do
    character
    |> cast(attrs, [:id, :created_at, :updated_at])
    |> cast_embed(:identity)
    |> cast_embed(:personality)
    |> cast_embed(:soulscript)
    |> cast_embed(:cognitive)
    |> cast_embed(:evolution)
    |> validate_required([:id, :soulscript])
  end

  # Public API delegates to Core
  defdelegate new(id \\ nil), to: JidoCharacter.Core
  defdelegate get(id), to: JidoCharacter.Core
  defdelegate update(character, attrs), to: JidoCharacter.Core
  defdelegate delete(id), to: JidoCharacter.Core
  defdelegate clone(character, new_id), to: JidoCharacter.Core
  defdelegate validate(character), to: JidoCharacter.Core
  defdelegate to_json(character), to: JidoCharacter.Core
  defdelegate from_json(json), to: JidoCharacter.Core

  # Template for creating new characters
  def template(attrs \\ %{}) do
    now = DateTime.utc_now()

    base = %__MODULE__{
      id: nil,
      created_at: now,
      updated_at: now,
      identity: JidoCharacter.Identity.template(),
      personality: JidoCharacter.Personality.template(),
      cognitive: %JidoCharacter.Cognitive{
        memories: [],
        knowledge: [],
        emotional: %JidoCharacter.Cognitive.Emotional{
          mood: "neutral",
          intensity: 0.5
        }
      },
      evolution: %JidoCharacter.Evolution{
        temporal_state: %JidoCharacter.Evolution.TemporalState{
          age: 0,
          maturity: 0.0,
          stage: "initial",
          last_evolved_at: now
        },
        growth_system: %JidoCharacter.Evolution.GrowthSystem{},
        history: []
      },
      soulscript: %JidoCharacter.SoulScript.Root{
        version: "1.0",
        id: UUID.uuid4(),
        entity: %JidoCharacter.SoulScript.Entity{
          form: "human"
        },
        personality: %JidoCharacter.SoulScript.Personality{
          name: "New Character"
        }
      }
    }

    struct(base, attrs)
  end
end
