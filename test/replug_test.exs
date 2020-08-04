defmodule ReplugTest do
  use ExUnit.Case
  use Plug.Test

  alias Replug.TestPlugs.SimpleAssign
  alias Replug.TestConfigs.SimpleConfig

  describe "Replug" do
    test "should reconfigure the intended plug per request" do
      opts =
        Replug.init(
          plug: SimpleAssign,
          opts: {SimpleConfig, :simple_assign}
        )

      conn =
        :get
        |> conn("/")
        |> Replug.call(opts)

      assert conn.assigns == %{value: "cool_thing"}
    end
  end
end
