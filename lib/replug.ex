defmodule Replug do
  @moduledoc """
  ```
  plug Replug,
    plug: {Corsica, max_age: 600, expose_headers: ~w(X-Foo)},
    opts: fn ->
      [origins: System.get_env("VALID_ORIGINS")]
    end
  ```

  or

  ```
  plug Replug,
    plug: Corsica,
    opts: fn ->
      [
        origins: System.get_env("VALID_ORIGINS"),
        max_age: 600,
        expose_headers: ~w(X-Foo)
      ]
    end
  ```

  """

  @behaviour Plug

  @impl true
  def init(opts) do
    plug =
      case Keyword.get(opts, :plug) do
        {module, opts} when is_atom(module) and is_list(opts) ->
          {module, opts}

        module when is_atom(module) ->
          {module, :only_dynamic_opts}

        nil ->
          raise("Replug requires a :plug entry")
      end

    %{
      plug: plug,
      opts: Keyword.get(opts, :opts) || raise("Replug requires a :opts entry")
    }
  end

  @impl true
  def call(conn, %{plug: {module, :only_dynamic_opts}, opts: opts_function}) do
    opts =
      opts_function.()
      |> module.init()

    module.call(conn, opts)
  end

  def call(conn, %{plug: {module, static_opts}, opts: opts_function}) do
    opts =
      static_opts
      |> merge_opts(opts_function.())
      |> module.init()

    module.call(conn, opts)
  end

  defp merge_opts(static_opts, dynamic_opts)
       when is_list(static_opts) and is_list(dynamic_opts) do
    Keyword.merge(static_opts, dynamic_opts)
  end

  defp merge_opts(static_opts, dynamic_opts) when is_map(static_opts) and is_map(dynamic_opts) do
    Map.merge(static_opts, dynamic_opts)
  end
end
