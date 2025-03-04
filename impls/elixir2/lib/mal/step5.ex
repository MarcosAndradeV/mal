defmodule Mal.Step6 do
  def run do
    env = Mal.Env.new()

    for {name, val} <- Mal.Core.namespace() do
      Mal.Env.set(env, name, val)
    end

    "(def! not (fn* (a) (if a false true)))" |> read() |> eval(env)
    repl(env)
  end

  @spec repl(pid()) :: String.t()
  defp repl(env), do: IO.gets("user> ") |> repl(env)

  @spec repl(:eof, pid()) :: no_return()
  defp repl(:eof, _env), do: exit(:normal)

  @spec repl(String.t(), pid()) :: String.t()
  defp repl(input, env) do
    input |> String.trim("\n") |> read() |> eval(env) |> print() |> IO.puts()
    repl(env)
  end

  defp read(string) do
    string |> Mal.Reader.read_str()
  end

  defp eval(ast, env) do
    # IO.puts("EVAL: #{Mal.Printer.pr_str(ast |> dbg())}")

    case ast do
      {:symbol, sym} ->
        Mal.Env.get(env, sym)

      {:mal_list, [{:symbol, "def!"}, {:symbol, name}, val]} ->
        val = eval(val, env)

        case val do
          {:mal_error, _} ->
            val

          _ ->
            Mal.Env.set(env, name, val)
            val
        end

      {:mal_list, [{:symbol, "let*"}, {n, args} | val]} when n in [:mal_list, :mal_vector] ->
        tmp = Mal.Env.new(env)

        Enum.map(args |> Enum.chunk_every(2), fn [{:symbol, k}, v] ->
          Mal.Env.set(tmp, k, eval(v, tmp))
        end)

        Enum.map(val, fn e -> eval(e, tmp) end) |> List.last()

      {:mal_list, [{:symbol, "do"} | args]} ->
        Enum.map(args, fn e -> eval(e, env) end) |> List.last()

      {:mal_list, [{:symbol, "if"}, cond, t, f]} ->
        res = eval(cond, env)

        if res == nil or res == false do
          eval(f, env)
        else
          eval(t, env)
        end

      {:mal_list, [{:symbol, "if"}, cond, t]} ->
        res = eval(cond, env)

        if res == nil or res == false do
          nil
        else
          eval(t, env)
        end

      {:mal_list, [{:symbol, "fn*"}, {n, params}, body]} when n in [:mal_list, :mal_vector] ->
        params = for {:symbol, symbol} <- params, do: symbol

        f = fn args ->
          tmp = Mal.Env.new(env, params, args)
          eval(body, tmp)
        end

        {:mal_function, f}

      {:mal_list, [func | args]} ->
        args = Enum.map(args, fn e -> eval(e, env) end)

        case eval(func, env) do
          {:mal_error, msg} -> {:mal_error, msg}
          {:mal_function, f} -> f.(args)
        end

      {:mal_vector, args} ->
        {:mal_vector, Enum.map(args, fn e -> eval(e, env) end)}

      {:mal_hash_map, args} ->
        {
          :mal_hash_map,
          args |> Enum.map(fn e -> eval(e, env) end)
          # |> Enum.chunk_every(2)
          # |> Enum.map(&List.to_tuple/1)
          # |> Enum.map(fn {k, v} -> Tuple.to_list({k, eval(v, env)}) end)
          # |> List.flatten()
        }

      val ->
        val
    end
  end

  defp print(ast) do
    ast |> Mal.Printer.pr_str()
  end
end
