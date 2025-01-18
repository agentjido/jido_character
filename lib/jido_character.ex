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

  # Extract & compose rich data from the character
  defdelegate compose(character, opts \\ []), to: JidoCharacter.Core

  # Future
  # @doc """
  # Retrieve a stable, core representation of the character:
  # - Static identity traits
  # - Core narrative
  # - Cultural constants

  # Returns a static snapshot of the character's foundational data.
  # """
  # @spec get_core_character_definition(t()) :: CoreCharacterDefinition.t()
  # def get_core_character_definition(character),
  #   do: JidoCharacter.Core.get_core_character_definition(character)

  # @doc """
  # Extract a relevant subset of character data for a particular scenario.
  # Given a request context (like a user query), select which
  # personality traits, memories, and context details matter.

  # Returns a scenario-focused subset of character data.
  # """
  # @spec get_contextual_character_data(t(), ScenarioDescription.t()) :: ContextualCharacterData.t()
  # def get_contextual_character_data(character, scenario),
  #   do: JidoCharacter.Core.get_contextual_character_data(character, scenario)

  # @doc """
  # Retrieve current persona or platform-specific variations of the character.
  # This allows the calling code to select a persona's unique overlay on top of core traits.

  # Returns persona-specific modifications or overrides to the core character definition.
  # """
  # @spec get_persona_overlay(t(), String.t()) :: PersonaOverlay.t()
  # def get_persona_overlay(character, persona_id),
  #   do: JidoCharacter.Core.get_persona_overlay(character, persona_id)

  # @doc """
  # Select and inject relevant knowledge items and memory entries.
  # Given a scenario or user prompt, this function filters the large memory/knowledge base
  # down to only those items most relevant for the LLM's next response.

  # Returns a filtered list of memory/knowledge entries.
  # """
  # @spec retrieve_relevant_memory_and_knowledge(t(), ScenarioDescription.t(), integer() | nil) ::
  #         MemoryAndKnowledgeSubset.t()
  # def retrieve_relevant_memory_and_knowledge(character, scenario, max_items \\ nil),
  #   do: JidoCharacter.Core.retrieve_relevant_memory_and_knowledge(character, scenario, max_items)

  # @doc """
  # Synthesize a final prompt layer from:
  # - Core character data
  # - Persona overlays (if any)
  # - Current context, including emotional state and world context
  # - Filtered knowledge and memory

  # This method composes a structured, role-based prompt that can then be serialized
  # into a single text prompt for the LLM.

  # Returns a structured prompt object that can be formatted for the LLM.
  # """
  # @spec compose_structured_prompt(t(), ScenarioDescription.t(), String.t() | nil) ::
  #         StructuredPrompt.t()
  # def compose_structured_prompt(character, scenario, persona_id \\ nil),
  #   do: JidoCharacter.Core.compose_structured_prompt(character, scenario, persona_id)

  # @doc """
  # Format the structured prompt into a text-based prompt suitable for the LLM.
  # Could apply templates from the character's config layer and ensure the final output
  # is well-organized with headings and hints for the LLM.

  # Returns a text prompt ready to be sent to the LLM.
  # """
  # @spec format_prompt_for_llm(StructuredPrompt.t()) :: String.t()
  # def format_prompt_for_llm(structured_prompt),
  #   do: JidoCharacter.Core.format_prompt_for_llm(structured_prompt)

  # @spec add_memory_item(character :: Character.t(), memory_item :: MemoryItem.t()) ::
  #         Character.t()
  # @spec update_emotional_state(character :: Character.t(), event :: any()) :: Character.t()
  # @spec evolve_persona_traits(character :: Character.t(), persona_id :: String.t()) ::
  #         Character.t()
  # @spec update_social_relationships(
  #         character :: Character.t(),
  #         relationship_changes :: list(RelationshipChange.t())
  #       ) :: Character.t()
  # @spec incorporate_new_knowledge(character :: Character.t(), knowledge_item :: KnowledgeItem.t()) ::
  #         Character.t()
end
