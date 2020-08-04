defmodule Replug.TestConfigs.SimpleConfig do
  def simple_assign_kw_list do
    [
      value: "cool_thing"
    ]
  end

  def simple_assign_map do
    %{
      value: "cool_thing"
    }
  end
end
