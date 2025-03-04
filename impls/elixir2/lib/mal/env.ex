defmodule Mal.EnvMap do
  defstruct outer: nil, env: %{}

  def get(%Mal.EnvMap{outer: nil, env: map}, key) do
    case Map.fetch(map, key) do
      {:ok, val} -> val
      :error -> {:mal_error, "'#{key}' not found"}
    end
  end

  def get(%Mal.EnvMap{outer: outer, env: map}, key) do
    case Map.fetch(map, key) do
      {:ok, val} -> val
      :error -> Mal.Env.get(outer, key)
    end
  end

  def set(map, key, val) do
    %{map | :env => Map.put(map.env, key, val)}
  end
end

defmodule Mal.Env do
  alias Mal.EnvMap

  def new(outer \\ nil, binds \\ [], expr \\ []) do
    pid =
      case Agent.start_link(fn -> %EnvMap{outer: outer} end) do
        {:ok, pid} -> pid
        {:error, reason} -> throw(reason)
      end

    set_bindings(pid, binds, expr)
  end

  defp set_bindings(pid, [], []), do: pid

  defp set_bindings(pid, ["&", key], exprs) do
    set(pid, key, {:mal_list, exprs})
    pid
  end

  defp set_bindings(pid, [key | binds], [value | exprs]) do
    set(pid, key, value)
    set_bindings(pid, binds, exprs)
  end

  def get(pid, key) do
    Agent.get(pid, fn env_map ->
      EnvMap.get(env_map, key)
    end)
  end

  def set(pid, key, val) do
    Agent.update(pid, fn env_map ->
      EnvMap.set(env_map, key, val)
    end)
  end
end
