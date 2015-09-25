defmodule Shkolinex.Dumper do
  def dump_to_csv(articles, file_name) do
    file = File.stream!(file_name)

    articles
    |> Stream.map(&(to_csv(&1)))
    |> CSV.encode()
    |> Enum.into(file)
  end

  defp to_csv(article) do
    [
      article.title,
      article.pubAt,
      article.url,
      article.newsId,
      article.author
    ]
  end
end
