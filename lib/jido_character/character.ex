defmodule JidoCharacter.Core do
  @moduledoc """
  Core implementation of JidoCharacter operations.
  Handles CRUD and utility functions while maintaining persistence.
  """

  alias JidoCharacter
  alias JidoCharacter.Composer

  @persist_adapter Application.compile_env(
                     :jido_character,
                     :persist_adapter,
                     JidoCharacter.Persistence.Memory
                   )

  @type character :: JidoCharacter.t()
  @type changeset :: JidoCharacter.changeset()
  @type error :: JidoCharacter.error()
  @doc "Creates a new character with optional ID"
  @spec new(String.t() | nil) :: {:ok, character()} | error()
  def new(id \\ nil) do
    id = id || UUID.uuid4()
    now = DateTime.utc_now()

    JidoCharacter.template(%{
      id: id,
      created_at: now,
      updated_at: now
    })
    |> JidoCharacter.changeset(%{})
    |> commit_changes()
  end

  @doc "Retrieves a character by ID"
  @spec get(String.t()) :: {:ok, character()} | {:error, :not_found}
  def get(id) when is_binary(id), do: @persist_adapter.get(id)

  @doc "Updates a character with new attributes"
  @spec update(character(), map()) :: {:ok, character()} | error()
  def update(%JidoCharacter{} = character, attrs) when is_map(attrs) do
    attrs = Map.put(attrs, :updated_at, DateTime.utc_now())

    character
    |> JidoCharacter.changeset(attrs)
    |> commit_changes()
  end

  @doc "Deletes a character by ID"
  @spec delete(String.t()) :: :ok | {:error, term()}
  def delete(id) when is_binary(id), do: @persist_adapter.delete(id)

  @doc "Creates a deep copy with a new ID"
  @spec clone(character(), String.t()) :: {:ok, character()} | error()
  def clone(%JidoCharacter{} = character, new_id) do
    attrs = %{
      id: new_id,
      name: character.name,
      description: character.description,
      created_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now(),
      identity: character.identity |> Map.from_struct()
    }

    JidoCharacter.template(attrs)
    |> JidoCharacter.changeset(%{})
    |> commit_changes()
  end

  @doc "Validates a character without persistence"
  @spec validate(character()) :: :ok | {:error, changeset()}
  def validate(%JidoCharacter{} = character) do
    case JidoCharacter.changeset(character, %{}) do
      %{valid?: true} -> :ok
      changeset -> {:error, changeset}
    end
  end

  @doc "Converts character to JSON string"
  @spec to_json(character()) :: {:ok, String.t()} | {:error, term()}
  def to_json(%JidoCharacter{} = character) do
    try do
      {:ok, Jason.encode!(character)}
    rescue
      e in Jason.EncodeError -> {:error, {:encoding_error, e.message}}
    end
  end

  @spec from_json(String.t()) :: {:ok, character()} | error()
  def from_json(json) when is_binary(json) do
    with {:ok, decoded} <- Jason.decode(json),
         # Convert string keys to atoms for embedded schemas
         decoded <- Map.new(decoded, fn {k, v} -> {String.to_existing_atom(k), v} end),
         # Create a new template with the decoded data
         character <- JidoCharacter.template(decoded),
         # Apply changes through changeset
         changeset <- JidoCharacter.changeset(character, %{}),
         %{valid?: true} <- changeset do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, %Jason.DecodeError{}} = error -> error
      %{valid?: false} = changeset -> {:error, changeset}
    end
  end

  def compose(%JidoCharacter{} = character, opts \\ []) do
    with {:ok, identity} <- Composer.compose(character.identity, opts) do
      #  {:ok, personality} <- Composer.compose(character.personality, opts) do
      composed = """
      #{identity}
      """

      {:ok, String.trim(composed)}
    end
  end

  # Private Helpers

  defp commit_changes(%Ecto.Changeset{} = changeset) do
    case changeset do
      %{valid?: true} = valid_changeset ->
        valid_changeset
        |> Ecto.Changeset.apply_changes()
        |> @persist_adapter.save()

      invalid_changeset ->
        {:error, invalid_changeset}
    end
  end

  @doc false
  def persist_adapter, do: @persist_adapter
end
