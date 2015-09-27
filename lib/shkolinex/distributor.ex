defmodule Shkolinex.Distributor do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def checkout do
    Agent.get_and_update(__MODULE__, fn urls ->
      case urls do
        [h|t] -> {{:url, h}, t}
        []    -> {:nojobs,  []}
      end
    end)
  end

  def enqueue_all(urls) do
    Agent.update(__MODULE__, fn _ -> urls end)
  end
end
