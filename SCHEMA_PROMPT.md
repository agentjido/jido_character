# Character Sub-Schema Implementation Guide

## Common Patterns Observed

### Schema Structure
1. All sub-schemas follow TypedEctoSchema
2. Use embedded_schema with @primary_key false
3. Implement standard derives for Inspect and Jason.Encoder
4. Follow a consistent module hierarchy (e.g., JidoCharacter.Identity.Base)

### Field Types and Validation
1. Use of typed fields with explicit types
2. Mix of scalar and complex types (arrays, maps)
3. Consistent default value patterns
4. Comprehensive validation rules

### Core Functions
Each sub-schema implements:
1. changeset/2
2. template/1
3. Domain-specific update functions
4. Helper functions for state management

## Implementation Template

### Basic Schema Structure
```elixir
defmodule JidoCharacter.Category.SubSchema do
  @moduledoc """
  Clear description of the sub-schema's purpose and role in the character system.
  """
  use TypedEctoSchema
  import Ecto.Changeset

  @derive Inspect
  @derive Jason.Encoder
  @primary_key false
  typed_embedded_schema do
    # Fields go here
  end
end
```

### Required Functions
```elixir
# Standard changeset function
def changeset(schema \\ %__MODULE__{}, attrs) do
  schema
  |> cast(attrs, [:field1, :field2])
  |> validate_required([:required_field])
  # Additional validations
end

# Template with defaults
@spec template(map()) :: %__MODULE__{}
def template(attrs \\ %{}) do
  %__MODULE__{
    field1: default_value1,
    field2: default_value2
  }
  |> Map.merge(attrs)
end
```

## Best Practices

### 1. Field Design
- Use appropriate Ecto types
- Define sensible defaults
- Consider validation requirements
- Document field purposes
- Group related fields logically

```elixir
field(:primary_data, :string)
field(:metadata, :map, default: %{})
field(:timestamps, {:array, :utc_datetime_usec}, default: [])
field(:status, Ecto.Enum, values: [:active, :inactive])
```

### 2. Validation Rules
- Implement comprehensive validation in changeset
- Use appropriate validation functions
- Custom validation for complex rules
- Clear error messages

```elixir
def changeset(schema, attrs) do
  schema
  |> cast(attrs, [:field1, :field2])
  |> validate_required([:field1])
  |> validate_length(:field1, max: 255)
  |> validate_inclusion(:field2, ["opt1", "opt2"])
  |> custom_validation()
end
```

### 3. State Management
- Immutable state updates
- Clear state transition functions
- Error handling for state changes

```elixir
@spec update_state(t(), map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
def update_state(schema, new_state) do
  schema
  |> changeset(%{state: new_state})
  |> apply_action(:update)
end
```

### 4. Type Specifications
- Define clear types
- Use type specs for public functions
- Document complex types

```elixir
@type t :: %__MODULE__{}
@type update_opts :: [atom()]
@spec update(t(), map(), update_opts()) :: {:ok, t()} | {:error, term()}
```

## Implementation Checklist

1. Schema Definition:
   - [ ] Clear @moduledoc
   - [ ] Appropriate derives
   - [ ] Typed fields with defaults
   - [ ] Logical field grouping

2. Core Functions:
   - [ ] changeset/2 implementation
   - [ ] template/1 with defaults
   - [ ] Type specifications
   - [ ] Domain-specific functions

3. Validation:
   - [ ] Required fields
   - [ ] Field constraints
   - [ ] Custom validations
   - [ ] Error messages

4. Integration:
   - [ ] Parent schema embedding
   - [ ] Proper namespace
   - [ ] Consistent API

5. Testing:
   - [ ] Unit tests
   - [ ] Property-based tests
   - [ ] Integration tests
   - [ ] Edge cases

## Common Patterns from Existing Sub-schemas

### Identity.Base (Static Data)
- Core identifiers
- Version tracking
- Type classification
- Tag system

### Identity.Style (Configuration)
- Behavioral preferences
- Formatting rules
- Customization options
- Default settings

### Identity.Profile (Temporal Data)
- Current state
- Public information
- Updateable content
- Visibility controls

## Anti-patterns to Avoid

1. Mixing Static and Temporal Data
   - Keep temporal data in dedicated schemas
   - Separate configuration from state

2. Inconsistent Validation
   - Missing required validations
   - Incomplete error handling
   - Insufficient type checking

3. Poor State Management
   - Mutable state
   - Unclear state transitions
   - Missing validation on updates

4. Inadequate Documentation
   - Missing type specs
   - Unclear field purposes
   - Incomplete function docs

## Testing Strategy

1. Unit Tests:
```elixir
describe "changeset/2" do
  test "validates required fields" do
    changeset = SubSchema.changeset(%SubSchema{}, %{})
    refute changeset.valid?
  end
end
```

2. Property Tests:
```elixir
property "always maintains valid state" do
  check all attrs <- generator() do
    changeset = SubSchema.changeset(%SubSchema{}, attrs)
    assert changeset.valid?
  end
end
```

## Documentation Template

```elixir
@moduledoc """
Represents [purpose/role] in the character system.

## Fields

* `:field1` - Description and purpose
* `:field2` - Description and purpose

## Examples

    iex> schema = SubSchema.template(%{field1: "value"})
    iex> {:ok, updated} = SubSchema.update_state(schema, %{field2: "new"})
"""
```