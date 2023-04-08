defmodule NimbleOptionsEx do
  @moduledoc """
  Set of custom functions to enhance the UX with `NimbleOptions`.
  """

  @doc """
  Validates a behaviour passed as a module or as a set of functions.

  _Example:_

  ```elixir
  schema = [
    container: [
      required: true,
      type: {:custom, NimbleOptionsEx, :behaviour, [Access]},
      doc: "The implementation of `Access` to be used as a main storage"
    ],
    …
  ]
  ```

  If no arguments are given, the checker would make sure the module
    passed is indeed a module, available at the moment of invocation.
  """
  @spec behaviour(module() | any(), module() | []) ::
          {:ok, validated_option :: module()} | {:error, NimbleOptions.ValidationError.t()}
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
         funs when is_list(funs) <- behaviour.behaviour_info(:callbacks) do
      behaviour(value, funs)
    else
      _ ->
        {:error, "schema is invalid, ‹" <> inspect(behaviour) <> "› is not a behaviour"}
    end
  end

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
end
