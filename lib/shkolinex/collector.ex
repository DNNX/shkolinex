defmodule Shkolinex.Collector do
  def collect_urls(urls) do
    me = self
    writer = spawn_link fn ->
      IO.puts("writer started")
      await_writer(me)
    end

    urls
    |> Enum.map(fn url ->
         Task.async(fn ->
           :timer.sleep(url * 100)
           send(writer, {:msg, url})
         end)
       end)
    |> Enum.map(&Task.await(&1))

    send(writer, :done)

    receive do
      :wdone -> IO.puts "OK ALL DONE"
    end
  end

  defp await_writer(owner) do
    receive do
      {:msg, msg} ->
        IO.puts("Got msg #{ inspect msg }")
        :timer.sleep(5)
        await_writer(owner)
      :done       ->
        IO.puts("I'm done for today")
        :timer.sleep(2000)
        send(owner, :wdone)
    end
  end

end
