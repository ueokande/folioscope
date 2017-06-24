module ArticleHelpers
  def plane_summary(article, length = nil, ellipsis='...')
    rendered = article.render(layout: false, keep_separator: true)
    text = Nokogiri::HTML.parse(rendered).text.strip
    if length && text.length > length
      text = text[0..length] + ellipsis if text.length > length
    end
    text
  end

  def first_paragraph_text(article)
    rendered = article.render(layout: false, keep_separator: false)
    tags = Nokogiri::HTML.parse(rendered).css('p')
    text = tags.map(&:text).find {|content| !content.empty? }
    text ? text.delete("\n") : article.title
  end

  def first_img_href(article)
    rendered = article.render(layout: false, keep_separator: false)
    img = Nokogiri::HTML.parse(rendered).css('img').first
    return nil unless img

    src = img.attribute("src").value
    URI.join(config[:endpoint], src).to_s
  end

  def href(article)
    URI.join(config[:endpoint], article.path).to_s
  end
end
