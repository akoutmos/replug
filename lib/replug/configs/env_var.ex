defmodule Replug.Configs.EnvVar do
  @moduledoc """
  This config module takes either a keyword list or a map where
  the keys are the option fields and the values are environment
  variable keys. The environment variable keys are then
  extrapolated out to their configured values. For example, if
  provided with a keyword list of:

  ```
  [opt_1: "ENV_VAR_OPT_1", opt_2: "ENV_VAR_OPT_2"]
  ```

  And the environment variables ENV_VAR_OPT_1 and ENV_VAR_OPT_2
  are set to "foo" and "bar" respectfully, then the output
  keyword list would be:

  ```
  [opt_1: "foo", opt_2: "bar"]
  ```
  """

  def resolve(opts) when is_list(opts) do
    Enum.map(opts, fn {key, env_var} ->
      {key, System.get_env(env_var)}
    end)
  end

  def resolve(opts) when is_map(opts) do
    opts
    |> Enum.map(fn {key, env_var} ->
      {key, System.get_env(env_var)}
    end)
    |> Map.new()
  end
end
