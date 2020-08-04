defmodule Replug.Configs.AppEnv do
  @moduledoc """
  This config module takes either a keyword list or a map where
  the keys are the option fields and the values are environment
  variable keys. The environment variable keys are then
  extrapolated out to their configured values. For example, if
  provided with a keyword list of:

  ```
  [opt_1: [:my_app, :host], opt_2: [:my_app, :port]]
  ```

  And the environment variables ENV_VAR_OPT_1 and ENV_VAR_OPT_2
  are set to "foo" and "bar" respectfully, then the output
  keyword list would be:

  ```
  [opt_1: "foo", opt_2: "bar"]
  ```
  """

  def resolve(opts) when is_list(opts) do
    Enum.map(opts, fn {key, [app, config_key]} ->
      {key, Application.get_env(app, config_key)}
    end)
  end

  def resolve(opts) when is_map(opts) do
    opts
    |> Enum.map(fn {key, [app, config_key]} ->
      {key, Application.get_env(app, config_key)}
    end)
    |> Map.new()
  end
end
