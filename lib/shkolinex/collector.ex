defmodule Shkolinex.Collector do
  def collect_urls(urls, file_name) do
    me = self
    writer = spawn_link fn ->
      IO.puts("writer started")
      await_writer(me, file_name, [])
    end

    distributor = spawn_link fn ->
      loop_distributor(urls)
    end

    1..8
    |> Enum.map(fn _ ->
        spawn_link(fn ->
           loop_worker(distributor, writer, me)
         end)
       end)
    |> Enum.map(fn _pid ->
         receive do :workerdone -> IO.puts("mkay") end
       end)

    send(writer, :done)

    receive do
      :wdone -> IO.puts "OK ALL DONE"
    end
  end

  defp loop_worker(distributor, writer, owner) do
    send distributor, {:wannajob, self}
    receive do
      {:url, url} ->
        articles = Shkolinex.Parser.scrape_url(url)
        send(writer, {:msg, articles, url})
        loop_worker(distributor, writer, owner)
      :nojobs ->
        send owner, :workerdone
        IO.puts "wkr done"
    end
  end

  defp loop_distributor([url|rest]) do
    receive do
      {:wannajob, worker} ->
        send worker, {:url, url}
        loop_distributor(rest)
    end
  end

  defp loop_distributor([]) do
    receive do
      {:wannajob, worker} ->
        send worker, :nojobs
        loop_distributor([])
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
