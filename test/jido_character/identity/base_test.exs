defmodule JidoCharacter.Identity.BaseTest do
  use ExUnit.Case, async: true
  alias JidoCharacter.Identity.Base

  describe "changeset/2" do
    test "validates required fields" do
      changeset = Base.changeset(%Base{}, %{})
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).unique_id
      assert "can't be blank" in errors_on(changeset).creation_timestamp
      assert "can't be blank" in errors_on(changeset).version
    end

    test "validates character_type inclusion" do
      attrs = %{
        unique_id: UUID.uuid4(),
        creation_timestamp: DateTime.utc_now(),
        version: 1,
        character_type: "invalid_type"
      }

      changeset = Base.changeset(%Base{}, attrs)
      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).character_type
    end

    test "validates version is greater than 0" do
      attrs = %{
        unique_id: UUID.uuid4(),
        creation_timestamp: DateTime.utc_now(),
        version: 0,
        character_type: "npc"
      }

      changeset = Base.changeset(%Base{}, attrs)
      refute changeset.valid?
      assert "must be greater than 0" in errors_on(changeset).version
    end

    test "validates tags length" do
      attrs = %{
        unique_id: UUID.uuid4(),
        creation_timestamp: DateTime.utc_now(),
        version: 1,
        character_type: "npc",
        tags: List.duplicate("tag", 21)
      }

      changeset = Base.changeset(%Base{}, attrs)
      refute changeset.valid?
      assert "should have at most 20 item(s)" in errors_on(changeset).tags
    end

    test "creates valid changeset with valid attributes" do
      attrs = %{
        unique_id: UUID.uuid4(),
        creation_timestamp: DateTime.utc_now(),
        version: 1,
        character_type: "npc",
        namespace: "test",
        tags: ["tag1", "tag2"]
      }

      changeset = Base.changeset(%Base{}, attrs)
      assert changeset.valid?
    end
  end

  describe "template/1" do
    test "creates a base template with default values" do
      base = Base.template()
      assert is_binary(base.unique_id)
      assert %DateTime{} = base.creation_timestamp
      assert base.character_type == "npc"
      assert base.version == 1
      assert base.namespace == "default"
      assert base.tags == []
    end

    test "merges provided attributes with defaults" do
      attrs = %{
        character_type: "player",
        namespace: "custom",
        tags: ["custom_tag"]
      }

      base = Base.template(attrs)
      assert is_binary(base.unique_id)
      assert %DateTime{} = base.creation_timestamp
      assert base.character_type == "player"
      assert base.version == 1
      assert base.namespace == "custom"
      assert base.tags == ["custom_tag"]
    end
  end

  # Helper function to convert changeset errors to a map
  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
