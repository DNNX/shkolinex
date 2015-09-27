defmodule Shkolinex do
  use Application

  def start(_type, _args) do
    Shkolinex.Supervisor.start_link
  end
end
