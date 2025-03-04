defmodule Mal.Step2 do
  @repl_env %{
    "+" => &+/2,
    "-" => &-/2,
    "*" => &*/2,
    "/" => &div/2
  }

  @spec repl() :: String.t()
  def repl, do: IO.gets("user> ") |> repl()

  @spec repl(:eof) :: no_return()
  def repl(:eof), do: exit(:normal)

  @spec repl(String.t()) :: String.t()
  def repl(input) do
    input |> String.trim("\n") |> read() |> eval(@repl_env) |> print() |> IO.puts()
    repl()
  end

  defp read(string) do
    string |> Mal.Reader.read_str()
  end

  defp eval(ast, env) do
    # IO.puts("EVAL: #{Mal.Printer.pr_str(ast |> dbg())}")

    case ast do
      {:symbol, sym} ->
        Map.get(env, sym, {:mal_error, "Symbol '#{sym}' not found"})

      {:mal_list, [func | args]} ->
        args = Enum.map(args, fn e -> eval(e, env) end)

        case eval(func, env) do
          {:mal_error, msg} -> {:mal_error, msg}
          f -> apply(f, args)
        end

      {:mal_vector, args} ->
        {:mal_vector, Enum.map(args, fn e -> eval(e, env) end)}

      {:mal_hash_map, args} ->
        {:mal_hash_map,
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
