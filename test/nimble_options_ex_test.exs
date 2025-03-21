defmodule NimbleOptionsExTest do
  use ExUnit.Case
  doctest NimbleOptionsEx

  describe "behaviour/2" do
    test "wrong schema" do
      schema = [container: [type: {:custom, NimbleOptionsEx, :behaviour, [No_Access]}]]

      assert {:error,
              %NimbleOptions.ValidationError{message: message, key: :container, value: Map}} =
               NimbleOptions.validate([container: Map], schema)

      assert message ==
               "invalid value for :container option: schema is invalid, ‹No_Access› is not implementing the expected behaviour"
    end

    test "wrong argument type (not a module)" do
      schema = [container: [type: {:custom, NimbleOptionsEx, :behaviour, [Access]}]]

      assert {:error,
              %NimbleOptions.ValidationError{message: message, key: :container, value: %{}}} =
               NimbleOptions.validate([container: %{}], schema)

      assert message =~
               "expected to be a module, implementing a behaviour, specified by ‹Access›, got: ‹%{}›"
    end

    test "wrong argument type (bad module)" do
      schema = [container: [type: {:custom, NimbleOptionsEx, :behaviour, [Access]}]]

      assert {:error,
              %NimbleOptions.ValidationError{message: message, key: :container, value: No_Module}} =
               NimbleOptions.validate([container: No_Module], schema)

      assert message =~ "cannot find the requested module ‹No_Module› (nofile)"
    end

    test "wrong argument type (not an implementation)" do
      schema = [container: [type: {:custom, NimbleOptionsEx, :behaviour, [Access]}]]

      assert {:error,
              %NimbleOptions.ValidationError{message: message, key: :container, value: DateTime}} =
               NimbleOptions.validate([container: DateTime], schema)

      assert message =~
               "module ‹DateTime› does not implement requested callbacks " <>
                 "‹[pop: 2, get_and_update: 3, fetch: 2]›"
    end

    test "wrong argument type (partial implementation)" do
      schema = [
        container: [type: {:custom, NimbleOptionsEx, :behaviour, [[compare: 2, no_compare: 0]]}]
      ]

      assert {:error,
              %NimbleOptions.ValidationError{message: message, key: :container, value: DateTime}} =
               NimbleOptions.validate([container: DateTime], schema)

      assert message =~
               "module ‹DateTime› does not implement requested callbacks ‹[no_compare: 0]›"
    end

    test "oll korrect" do
      schema = [
        container: [type: {:custom, NimbleOptionsEx, :behaviour, [Access]}]
      ]

      assert {:ok, container: Map} = NimbleOptions.validate([container: Map], schema)
    end
  end

  describe "access?/1" do
    test "ok" do
      schema = [container: [type: {:custom, NimbleOptionsEx, :access?, []}]]

      assert {:ok, _} = NimbleOptions.validate([container: %S{}], schema)

      assert {:error,
              %NimbleOptions.ValidationError{
                message:
                  "invalid value for :container option: module ‹DateTime› does not implement requested callbacks ‹[pop: 2, get_and_update: 3, fetch: 2]›",
                key: :container,
                value: %DateTime{},
                keys_path: []
              }} = NimbleOptions.validate([container: DateTime.utc_now()], schema)
    end
  end

  describe "property/2" do
    test "simple type" do
      schema = [prop: [type: {:custom, NimbleOptionsEx, :property, [:string]}]]

      assert {:ok, _result} = NimbleOptions.validate([prop: {:foo, "bar"}], schema)

      assert {:error, %NimbleOptions.ValidationError{}} =
               NimbleOptions.validate([prop: {:foo, :bar}], schema)
    end

    test "strict keyword type" do
      schema = [prop: [type: {:custom, NimbleOptionsEx, :property, [foo: :string]}]]

      assert {:ok, _result} = NimbleOptions.validate([prop: {:foo, "bar"}], schema)

      assert {:error, %NimbleOptions.ValidationError{}} =
               NimbleOptions.validate([prop: {:foo, :bar}], schema)
    end
  end
end
