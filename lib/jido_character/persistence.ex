defmodule JidoCharacter.Persistence.Adapter do
  @moduledoc """
  Behaviour defining the persistence interface for JidoCharacter storage.
  """

  alias JidoCharacter

  @callback save(JidoCharacter.t()) :: {:ok, JidoCharacter.t()} | {:error, term()}
  @callback get(String.t()) :: {:ok, JidoCharacter.t()} | {:error, :not_found}
  @callback delete(String.t()) :: :ok | {:error, term()}
end
