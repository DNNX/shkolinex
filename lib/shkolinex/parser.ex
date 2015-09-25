defmodule Shkolinex.Parser do
  def scrape_url(url) do
    res = HTTPoison.get!(url)
    scrape_page(res.body)
  end

  def scrape_page(page) do
    Floki.find(page, "article.b-posts-1-item")
    |> Enum.map(&parse_article(&1))
  end

  defp parse_article(html) do
    %{
      title:
        html
        |> Floki.find("h3 a span")
        |> hd()
        |> Floki.text(deep: false),
      pubAt:
        html
        |> Floki.find("time")
        |> Floki.attribute("datetime")
        |> hd,
      newsId:
        html
        |> Floki.find(".show_news_view_count")
        |> Floki.attribute("news_id")
        |> hd,
      author:
        html
        |> Floki.find(".right-side")
        |> Floki.text(deep: false)
        |> String.strip(?.)
        |> String.strip,
      url:
        html
        |> Floki.find("h3 a")
        |> Floki.attribute("href")
        |> hd
    }
  end
end
