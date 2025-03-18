defmodule NimbleOptionsEx do
  @moduledoc """
  Set of custom functions to enhance the UX with `NimbleOptions`.
  """

  @doc """
  Validates a behaviour specified as a module or as a set of functions.

  _Example:_

      iex> schema = [
      ...>   container: [
      ...>     required: true,
      ...>     type: {:custom, NimbleOptionsEx, :behaviour, [Supervisor]},
      ...>     doc: "The implementation of `Supervisor` to be used as a supervisor"
      ...>   ]
      ...> ]
      iex> NimbleOptions.validate([container: DynamicSupervisor], schema)
      {:ok, [container: DynamicSupervisor]}
      iex> NimbleOptions.validate([container: DateTime], schema)
      {:error, %NimbleOptions.ValidationError{
        message: "invalid value for :container option: module ‹DateTime› does not implement requested callbacks ‹[init: 1]›",
        key: :container, value: DateTime, keys_path: []}}

  If no arguments are given, the checker would make sure the module
    passed is indeed a module, available at the moment of invocation.

  ---

  Please note, that `Access` behaviour is somewhat special, because
    it’s supported for _terms_, such as maps `%{foo: :bar}` (not `Map`,)
    keywords `[foo: :bar]` (not `Keyword`,) and structs `%Strct{foo: :bar}`
    (not `Strct` module itself.) Use `access?/1` validator to check
    whether `Access` is supported _by a term itself_.
  """
  @spec behaviour(module() | any(), module() | {module(), :strict} | []) ::
          {:ok, validated_option :: module()} | {:error, String.t()}
  def behaviour(value, funs_or_behaviour \\ [])

  def behaviour(value, behaviour) when not is_atom(value) do
    {:error,
     "expected to be a module, implementing a behaviour, " <>
       "specified by ‹" <>
       inspect(behaviour) <>
       "›, got: ‹" <>
       inspect(value) <> "›"}
  end

  def behaviour(value, behaviour) when is_atom(behaviour) do
    with {:module, ^behaviour} <- Code.ensure_compiled(behaviour),
         true <- function_exported?(behaviour, :behaviour_info, 1),
         funs when is_list(funs) <-
           behaviour.behaviour_info(:callbacks) -- behaviour.behaviour_info(:optional_callbacks) do
      behaviour(value, funs)
    else
      _ ->
        {:error,
         "schema is invalid, ‹" <>
           inspect(behaviour) <> "› is not implementing the expected behaviour"}
    end
  end

  def behaviour(value, {behaviour, :strict}) when is_atom(behaviour) do
    with {:module, ^behaviour} <- Code.ensure_compiled(behaviour),
         true <- function_exported?(behaviour, :behaviour_info, 1),
         funs when is_list(funs) <-
           behaviour.behaviour_info(:callbacks) do
      behaviour(value, funs)
    else
      _ ->
        {:error,
         "schema is invalid, ‹" <>
           inspect(behaviour) <> "› is not strictly implementing the expected behaviour"}
    end
  end

  def behaviour(value, {:strict, behaviour}) when is_atom(behaviour),
    do: behaviour(value, {behaviour, :strict})

  def behaviour(value, strict: behaviour) when is_atom(behaviour),
    do: behaviour(value, {behaviour, :strict})

  def behaviour(value, funs) when is_list(funs) do
    case Code.ensure_compiled(value) do
      {:module, ^value} ->
        funs
        |> Enum.reject(fn {fun, arity} -> function_exported?(value, fun, arity) end)
        |> case do
          [] ->
            {:ok, value}

          not_exported when is_list(not_exported) ->
            {:error,
             "module ‹" <>
               inspect(value) <>
               "› does not implement requested callbacks ‹" <> inspect(not_exported) <> "›"}
        end

      {:error, error} ->
        {:error, "cannot find the requested module ‹" <> inspect(value) <> "› (#{error})"}
    end
  end

  @doc """
  Validates that the term passed implements `Access` behaviour.

  _Example:_

      iex> schema = [
      ...>   container: [
      ...>     required: true,
      ...>     type: {:custom, NimbleOptionsEx, :access?, []},
      ...>     doc: "The implementation of `Access` to be used as a storage"
      ...>   ]
      ...> ]
      iex> NimbleOptions.validate([container: %{}], schema)
      {:ok, [container: %{}]}
      iex> NimbleOptions.validate([container: [foo: :bar]], schema)
      {:ok, [container: [foo: :bar]]}
      iex> NimbleOptions.validate([container: [1, 2, 3]], schema)
      {:error, %NimbleOptions.ValidationError{
        message: "invalid value for :container option: expected a keyword list, got a list ‹[1, 2, 3]›",
        key: :container, value: [1, 2, 3], keys_path: []}}
  """
  @spec access?(term()) ::
          {:ok, validated_option :: module()} | {:error, String.t()}
  def access?(nil), do: {:ok, nil}

  def access?(value) when is_list(value) do
    if Keyword.keyword?(value),
      do: {:ok, value},
      else: {:error, "expected a keyword list, got a list ‹" <> inspect(value) <> "›"}
  end

  def access?(%type{} = value) do
    with {:ok, ^type} <- behaviour(type, Access), do: {:ok, value}
  end

  def access?(%{} = value), do: {:ok, value}

  @doc """
  Validates that the term passed is a `prop`, a member of a `prop_list`.

  _Example:_

      iex> schema = [
      ...>   prop: [
      ...>     required: true,
      ...>     type: {:custom, NimbleOptionsEx, :property, [:string]},
      ...>     doc: "The property of type `{atom(), binary()}`"
      ...>   ]
      ...> ]
      iex> NimbleOptions.validate([prop: {:foo, "bar"}], schema)
      {:ok, [prop: {:foo, "bar"}]}
      iex> NimbleOptions.validate([prop: {:foo, 42}], schema)
      {:error, %NimbleOptions.ValidationError{
          message: "invalid value for :prop option: invalid value for :foo option: expected string, got: 42",
          key: :prop, keys_path: [], value: {:foo, 42}}}
  """
  @spec property(term(), atom() | tuple() | keyword()) ::
          {:ok, validated_option :: module()} | {:error, String.t()}
  def property({atom, type}, [{_, _} | _] = expected_type) when is_atom(atom) do
    case Keyword.fetch(expected_type, atom) do
      {:ok, expected_type} ->
        property({atom, type}, expected_type)

      :error ->
        {:error,
         "expected a tuple, with a key from ‹#{inspect(Keyword.keys(expected_type))}" <>
           "›, got: ‹" <> inspect({atom, type}) <> "›"}
    end
  end

  def property({atom, type}, expected_type) when is_atom(atom) do
    case NimbleOptions.validate([{atom, type}], [{atom, type: expected_type}]) do
      {:ok, [{^atom, _} = result]} -> {:ok, result}
      {:error, %NimbleOptions.ValidationError{message: message}} -> {:error, message}
      other -> {:error, "Failed to validate property ‹" <> inspect(other) <> "›"}
    end
  rescue
    ArgumentError -> property({atom, type}, [expected_type])
  end

  def property(other, expected_type) do
    {:error,
     "expected a tuple, with a second element being ‹" <>
       inspect(expected_type) <> "›, got: ‹" <> inspect(other) <> "›"}
  end
end
