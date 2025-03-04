defmodule Mal.Step0 do

  @spec repl() :: String.t()
  def repl, do: IO.gets("user> ") |> repl()

  @spec repl(:eof) :: no_return()
  def repl(:eof), do: exit(:normal)

  @spec repl(String.t()) :: String.t()
  def repl(input) do
    input |> String.trim("\n") |> read() |> eval() |> print() |> IO.puts()
    repl()
  end

  @spec read(String.t()) :: String.t()
  defp read(string) do
    string
  end

  @spec eval(String.t()) :: String.t()
  defp eval(string) do
    string
  end

  @spec print(String.t()) :: String.t()
  defp print(string) do
    string
  end
end
