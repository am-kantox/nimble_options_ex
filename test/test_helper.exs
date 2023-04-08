defmodule S do
  defstruct foo: :bar

  @behaviour Access

  @impl Access
  def fetch(%S{foo: foo}, :foo), do: {:ok, foo}
  @impl Access
  def get_and_update(%S{foo: foo} = data, :foo, _function), do: {foo, data}
  @impl Access
  def pop(%S{foo: foo} = data, :foo), do: {foo, data}
end

ExUnit.start()
