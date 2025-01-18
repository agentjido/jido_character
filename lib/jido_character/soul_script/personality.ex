defmodule JidoCharacter.SoulScript.Personality do
  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :core_traits, :values, :voice, :relationship]}
  @primary_key false
  typed_embedded_schema do
    field(:name, :string)
    embeds_many(:core_traits, JidoCharacter.SoulScript.Personality.Trait)
    embeds_many(:values, JidoCharacter.SoulScript.Personality.Value)
    embeds_one(:voice, JidoCharacter.SoulScript.Personality.Voice)
    embeds_one(:relationship, JidoCharacter.SoulScript.Personality.Relationship)
  end

  def changeset(personality, attrs) do
    personality
    |> cast(attrs, [:name])
    |> cast_embed(:core_traits)
    |> cast_embed(:values)
    |> cast_embed(:voice)
    |> cast_embed(:relationship)
    |> validate_required([:name])
  end
end
