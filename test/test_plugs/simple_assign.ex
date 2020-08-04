defmodule Replug.TestPlugs.SimpleAssign do
  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts) do
    opts
  end

  @impl true
  def call(conn, values) do
    Enum.reduce(values, conn, fn {key, value}, conn ->
      assign(conn, key, value)
    end)
  end
end
