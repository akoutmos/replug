defmodule ReplugTest do
  use ExUnit.Case, async: false
  use Plug.Test

  alias Replug.TestPlugs.SimpleAssign
  alias Replug.TestConfigs.SimpleConfig

  describe "Replug" do
    test "should reconfigure the intended plug per request" do
      opts =
        Replug.init(
          plug: SimpleAssign,
          opts: {SimpleConfig, :simple_assign_kw_list}
        )

      conn =
        :get
        |> conn("/")
        |> Replug.call(opts)

      assert conn.assigns == %{value: "cool_thing"}
    end

    test "should merge static and dynamic keyword list options" do
      opts =
        Replug.init(
          plug: {SimpleAssign, static_opts: "dummy_value"},
          opts: {SimpleConfig, :simple_assign_kw_list}
        )

      conn =
        :get
        |> conn("/")
        |> Replug.call(opts)

      assert conn.assigns == %{value: "cool_thing", static_opts: "dummy_value"}
    end

    test "should merge static and dynamic map options" do
      opts =
        Replug.init(
          plug: {SimpleAssign, %{static_opts: "dummy_value"}},
          opts: {SimpleConfig, :simple_assign_map}
        )

      conn =
        :get
        |> conn("/")
        |> Replug.call(opts)

      assert conn.assigns == %{value: "cool_thing", static_opts: "dummy_value"}
    end

    test "should resolve environment variable when using the EnvVar config module" do
      System.put_env("SOME_VALUE", "some_config_string")

      opts =
        Replug.init(
          plug: {SimpleAssign, [static_opts: "dummy_value"]},
          opts: {Replug.Configs.EnvVar, :resolve, [some_value: "SOME_VALUE"]}
        )

      conn =
        :get
        |> conn("/")
        |> Replug.call(opts)

      assert conn.assigns == %{some_value: "some_config_string", static_opts: "dummy_value"}
    end

    test "should resolve environment variable when using the AppEnv config module" do
      Application.put_env(:my_app, :app_config_test, "some_config_string")

      opts =
        Replug.init(
          plug: {SimpleAssign, %{static_opts: "dummy_value"}},
          opts: {Replug.Configs.AppEnv, :resolve, %{some_value: [:my_app, :app_config_test]}}
        )

      conn =
        :get
        |> conn("/")
        |> Replug.call(opts)

      assert conn.assigns == %{some_value: "some_config_string", static_opts: "dummy_value"}
    end

    test "should raise an error when required :opts are not provided" do
      assert_raise RuntimeError, "Replug requires a :opts entry", fn ->
        Replug.init(plug: SimpleAssign)
      end
    end

    test "should raise an error when required :plug is not provided" do
      assert_raise RuntimeError, "Replug requires a :plug entry with a module or tuple value", fn ->
        Replug.init(opts: {SimpleConfig, :simple_assign_kw_list})
      end
    end
  end
end
