defmodule JidoCharacter.Identity.Base do
  @moduledoc """
  Core, unchanging identity attributes that form the foundation of a character's identity.
  """
  use TypedEctoSchema
  import Ecto.Changeset

  @derive Inspect
  @derive Jason.Encoder
  @primary_key false
  typed_embedded_schema do
    field(:unique_id, :string)
    field(:creation_timestamp, :utc_datetime_usec)
    field(:character_type, :string)
    field(:version, :integer)
    field(:namespace, :string)
    field(:tags, {:array, :string})
  end

  def changeset(base \\ %__MODULE__{}, attrs) do
    base
    |> cast(attrs, [:unique_id, :creation_timestamp, :character_type, :version, :namespace, :tags])
    |> validate_required([:unique_id, :creation_timestamp, :version])
    |> validate_inclusion(:character_type, ["npc", "player", "system"])
    |> validate_number(:version, greater_than: 0)
    |> validate_length(:tags, max: 20)
  end

  @spec template(map()) :: %__MODULE__{}
  def template(attrs \\ %{}) do
    %__MODULE__{
      unique_id: UUID.uuid4(),
      creation_timestamp: DateTime.utc_now(),
      character_type: "npc",
      version: 1,
      namespace: "default",
      tags: []
    }
    |> Map.merge(attrs)
  end
end
