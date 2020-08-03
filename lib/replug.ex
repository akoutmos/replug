defmodule Replug do
  @moduledoc """
  ```
  # ---- router.ex ----
  plug Replug,
    plug: Corsica,
    opts: {MyAppWeb.PlugConfigs, :corsica}

  # ---- plug_configs.ex ----
  defmodule MyAppWeb.PlugConfigs do
    def corsica do
      [
        max_age: System.get_env("CORSICA_MAX_AGE"),
        expose_headers: ~w(X-Foo),
        origins: System.get_env("VALID_ORIGINS")
      ]
    end
  end
  ```
  """

  @behaviour Plug

  @impl true
  def init(opts) do
    plug =
      case Keyword.get(opts, :plug) do
        {plug_module, opts} when is_atom(plug_module) and is_list(opts) ->
          {plug_module, opts}

        plug_module when is_atom(plug_module) ->
          {plug_module, :only_dynamic_opts}

        nil ->
          raise("Replug requires a :plug entry with a module or tuple value")
      end

    %{
      plug: plug,
      opts: Keyword.get(opts, :opts) || raise("Replug requires a :opts entry")
    }
  end

  @impl true
  def call(conn, %{plug: {plug_module, :only_dynamic_opts}, opts: {opts_module, opts_function}}) do
    opts =
      opts_module
      |> apply(opts_function, [])
      |> plug_module.init()

    plug_module.call(conn, opts)
  end

  def call(conn, %{plug: {plug_module, static_opts}, opts: {opts_module, opts_function}}) do
    dynamic_opts = apply(opts_module, opts_function)

    opts =
      static_opts
      |> merge_opts(dynamic_opts)
      |> plug_module.init()

    plug_module.call(conn, opts)
  end

  defp merge_opts(static_opts, dynamic_opts)
       when is_list(static_opts) and is_list(dynamic_opts) do
    Keyword.merge(static_opts, dynamic_opts)
  end

  defp merge_opts(static_opts, dynamic_opts) when is_map(static_opts) and is_map(dynamic_opts) do
    Map.merge(static_opts, dynamic_opts)
  end
end
