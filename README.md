# NimbleOptionsEx [![Kantox ❤ OSS](https://img.shields.io/badge/❤-kantox_oss-informational.svg)](https://kantox.com/)  ![Test](https://github.com/am-kantox/nimble_options_ex/workflows/Test/badge.svg)  ![Dialyzer](https://github.com/am-kantox/nimble_options_ex/workflows/Dialyzer/badge.svg)

## Addons to [`NimbleOptions`](https://hexdocs.pm/nimble_options)

### `behaviour/2`

```elixir
schema = [
  container: [
    required: true,
    type: {:custom, NimbleOptionsEx, :behaviour, [Supervisor]},
    doc: "The implementation of `Supervisor` to be used as a supervisor"
  ]
]

NimbleOptions.validate([container: DynamicSupervisor], schema)
#⇒ {:ok, [container: DynamicSupervisor]}

NimbleOptions.validate([container: DateTime], schema)
#⇒ {:error, %NimbleOptions.ValidationError{
#    message: "[…] ‹DateTime› does not implement requested callbacks ‹[init: 1]›",
#    key: :container, value: DateTime, keys_path: []}}
```

### `access?/1`

```elixir
schema = [
  container: [
    required: true,
    type: {:custom, NimbleOptionsEx, :access?, []},
    doc: "The implementation of `Access` to be used as a storage"
  ]
]

NimbleOptions.validate([container: %{}], schema)
#⇒ {:ok, [container: %{}]}
NimbleOptions.validate([container: [foo: :bar]], schema)
#⇒ {:ok, [container: [foo: :bar]]}
NimbleOptions.validate([container: [1, 2, 3]], schema)
#⇒ {:error, %NimbleOptions.ValidationError{
#    message: "[…] expected a keyword list, got a list ‹[1, 2, 3]›",
#    key: :container, value: [1, 2, 3], keys_path: []}}
```

## Installation

```elixir
def deps do
  [
    {:nimble_options_ex, "~> 0.1"}
  ]
end
```

## [Documentation](https://hexdocs.pm/nimble_options_ex)

