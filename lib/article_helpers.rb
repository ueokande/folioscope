module ArticleHelpers
  def plane_summary(article, length = nil, ellipsis='...')
    rendered = article.render(layout: false, keep_separator: true)
    text = Nokogiri::HTML.parse(rendered).text.strip
    if length && text.length > length
      text = text[0..length] + ellipsis if text.length > length
    end
    text
  end
end
