# Replug

[![Hex.pm](https://img.shields.io/hexpm/v/replug.svg)](http://hex.pm/packages/replug) [![Build Status](https://travis-ci.org/akoutmos/replug.svg?branch=master)](https://travis-ci.org/akoutmos/replug) [![Coverage Status](https://coveralls.io/repos/github/akoutmos/replug/badge.svg?branch=master)](https://coveralls.io/github/akoutmos/replug?branch=master)

Replug is a sister library for [Unplug](https://github.com/akoutmos/unplug) thats aims to provide the functionality that
is out of scope for the Unplug library. Specifically, while Unplug allows you to conditionally execute Plugs, Replug
allows you to configure arbitrary Plugs at run-time even if the Plugs don't directly support run-time configuration.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `replug` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:replug, "~> 0.1.0"}
  ]
end
```

## Usage

Replug can be used anywhere you would typically use the `plug` macro. For example, let's say you want
to configure some non-configurable fields in Corsica, you could do the following:

```elixir
# ---- router.ex ----
plug Replug,
  plug: {Corsica, expose_headers: ~w(X-Foo)},
  opts: {MyAppWeb.PlugConfigs, :corsica}

# ---- plug_configs.ex ----
defmodule MyAppWeb.PlugConfigs do
  def corsica do
    [
      max_age: System.get_env("CORSICA_MAX_AGE"),
      origins: System.get_env("VALID_ORIGINS")
    ]
  end
end
```

This will wrap the call to Corsica's Plug and manually invoke Corsica's `init/1` function and it's `call/2` function
while providing run-time configuration.
