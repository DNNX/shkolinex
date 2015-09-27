defmodule Shkolinex.Collector do
  use GenServer

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def collect_urls(urls, file_name) do
    GenServer.call(__MODULE__, {:collect_urls, urls, file_name}, :infinity)
  end

  # Server (callbacks)

  def handle_call({:collect_urls, urls, file_name}, _from, state) do
    me = self
    writer = spawn_link fn ->
      IO.puts("writer started")
      await_writer(me, file_name, [])
    end

    Shkolinex.Distributor.start_link
    Shkolinex.Distributor.enqueue_all(urls)

    1..8
    |> Enum.map(fn _ ->
        spawn_link(fn ->
           loop_worker(writer, me)
         end)
       end)
    |> Enum.map(fn _pid ->
         receive do :workerdone -> IO.puts("mkay") end
       end)

    send(writer, :done)

    receive do
      :wdone -> IO.puts "OK ALL DONE"
    end

    {:reply, :ok, state}
  end

  defp loop_worker(writer, owner) do
    case Shkolinex.Distributor.checkout do
      {:url, url} ->
        articles = Shkolinex.Parser.scrape_url(url)
        send(writer, {:msg, articles, url})
        loop_worker(writer, owner)
      :nojobs ->
        send owner, :workerdone
        IO.puts "wkr done"
    end
  end

  defp await_writer(owner, file_name, acc) do
    receive do
      {:msg, articles, url} ->
        IO.puts("Got articles #{ length articles } from #{ url }")
        await_writer(owner, file_name, articles ++ acc)
      :done       ->
        Shkolinex.Dumper.dump_to_csv(acc, file_name)
        IO.puts("I'm done for today")
        send(owner, :wdone)
    end
  end
end
