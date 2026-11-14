defmodule CharacterV3ContractTest do
  use ExUnit.Case, async: true

  test "character context crosses the consolidated AI boundary without a model call" do
    assert {:ok, character} = Jido.Character.new(%{name: "Contract", instructions: ["Use short answers."]})
    assert {:ok, changed} = Jido.Character.update(character, %{name: "Updated"})
    assert {:ok, _} = Jido.Character.validate(changed)
    context = Jido.Character.to_context(changed)
    assert %ReqLLM.Context{} = context
    assert {:ok, lifecycle} = Jido.AI.Context.new(context)
    assert lifecycle.request.context == context
    assert Jido.Character.to_system_prompt(changed) =~ "Updated"
    assert Jido.Character.to_system_prompt(changed) =~ "Use short answers."
    assert {:error, _} = Jido.Character.new(%{name: 123})
    assert Application.get_application(Jido.AI.Context) == :jido
    assert Application.get_application(Jido.Action) == :jido
    assert Application.get_application(Jido.Signal) == :jido
  end
end
