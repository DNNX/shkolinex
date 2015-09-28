defmodule Shkolinex.DownloadWorker do
  use GenServer

  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:download, url}, from, state) do
    articles = Shkolinex.Parser.scrape_url(url)
    IO.puts("Downloaded articles #{ length articles } from #{ url }")
    {:reply, articles, state}
  end

  def handle_call(data, from, state) do
    super(data, from, state)
  end
end
