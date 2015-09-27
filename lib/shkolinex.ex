defmodule Shkolinex do
  use Application

  def start(_type, _args) do

    {:ok, spawn_link fn -> IO.puts("123123123") end}
  end
end
