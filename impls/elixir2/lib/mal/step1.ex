defmodule Mal.Step1 do
  @spec repl() :: String.t()
  def repl, do: IO.gets("user> ") |> repl()

  @spec repl(:eof) :: no_return()
  def repl(:eof), do: exit(:normal)

  @spec repl(String.t()) :: String.t()
  def repl(input) do
    input |> String.trim("\n") |> read() |> print() |> IO.puts()
    repl()
  end

  defp read(string) do
    string |> Mal.Reader.read_str()
  end

  defp print(ast) do
    ast |> Mal.Printer.pr_str()
  end
end
