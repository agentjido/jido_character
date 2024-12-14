defmodule JidoCharacterTest do
  use ExUnit.Case, async: true
  doctest JidoCharacter

  alias JidoCharacter

  # Setup block to configure test environment and start Memory adapter
  setup do
    # Configure the application to use Memory adapter
    :ok = Application.put_env(:jido_character, :persist_adapter, JidoCharacter.Persistence.Memory)

    # Start a fresh Memory adapter for each test
    start_supervised!(JidoCharacter.Persistence.Memory)

    :ok
  end

  describe "new/1" do
    test "creates a new character with generated id" do
      assert {:ok, character} = JidoCharacter.new()
      assert is_binary(character.id)
      assert %DateTime{} = character.created_at
      assert %DateTime{} = character.updated_at
      assert character.created_at == character.updated_at
      assert is_nil(character.name)
      assert is_nil(character.description)
    end

    test "creates a new character with provided id" do
      id = "test-id-123"
      assert {:ok, character} = JidoCharacter.new(id)
      assert character.id == id
    end
  end

  describe "get/1" do
    test "retrieves an existing character" do
      {:ok, created} = JidoCharacter.new("test-get")
      assert {:ok, retrieved} = JidoCharacter.get("test-get")
      assert created.id == retrieved.id
      assert created.created_at == retrieved.created_at
    end

    test "returns error for non-existent character" do
      assert {:error, :not_found} = JidoCharacter.get("non-existent")
    end
  end

  describe "update/2" do
    test "updates character attributes" do
      {:ok, character} = JidoCharacter.new()
      # Ensure timestamp difference
      Process.sleep(1)

      new_attrs = %{
        name: "Test Character",
        description: "A character for testing purposes"
      }

      assert {:ok, updated} = JidoCharacter.update(character, new_attrs)
      assert updated.name == "Test Character"
      assert updated.description == "A character for testing purposes"
      assert DateTime.compare(updated.updated_at, character.updated_at) == :gt
    end

    test "validates updates" do
      {:ok, character} = JidoCharacter.new()

      invalid_attrs = %{
        # Assuming there's a max length validation
        name: String.duplicate("a", 257)
      }

      assert {:error, changeset} = JidoCharacter.update(character, invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "delete/1" do
    test "removes an existing character" do
      {:ok, character} = JidoCharacter.new()
      assert :ok = JidoCharacter.delete(character.id)
      assert {:error, :not_found} = JidoCharacter.get(character.id)
    end
  end

  describe "clone/2" do
    test "creates a deep copy with new id" do
      {:ok, original} = JidoCharacter.new()

      {:ok, original} =
        JidoCharacter.update(original, %{
          name: "Original Character",
          description: "This is the original character"
        })

      new_id = "cloned-123"
      assert {:ok, cloned} = JidoCharacter.clone(original, new_id)
      assert cloned.id == new_id
      assert cloned.name == original.name
      assert cloned.description == original.description
      assert DateTime.compare(cloned.created_at, original.created_at) == :gt
    end
  end

  describe "validate/1" do
    test "validates valid character" do
      {:ok, character} = JidoCharacter.new()
      assert :ok = JidoCharacter.validate(character)
    end

    test "returns error for invalid character" do
      character = %JidoCharacter{id: nil}
      assert {:error, changeset} = JidoCharacter.validate(character)
      refute changeset.valid?
    end
  end

  describe "to_json/1 and from_json/1" do
    test "serializes and deserializes character" do
      {:ok, original} = JidoCharacter.new()

      new_attrs = %{
        name: "JSON Test Character",
        description: "A character for testing JSON serialization"
      }

      {:ok, original} = JidoCharacter.update(original, new_attrs)

      assert {:ok, json} = JidoCharacter.to_json(original)
      assert {:ok, decoded} = JidoCharacter.from_json(json)
      assert decoded.id == original.id
      assert decoded.name == original.name
      assert decoded.description == original.description
    end

    test "handles invalid json" do
      assert {:error, %Jason.DecodeError{}} = JidoCharacter.from_json("invalid json")
    end
  end

  # Property-based tests could be added here using StreamData
  # Example structure for future implementation:
  #
  # property "character maintains integrity through json roundtrip" do
  #   check all character <- character_generator() do
  #     {:ok, json} = JidoCharacter.to_json(character)
  #     {:ok, decoded} = JidoCharacter.from_json(json)
  #     assert character == decoded
  #   end
  # end
end
