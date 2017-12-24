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

  def facebook_share_href(article, length = nil, ellipsis='...')
    "https://www.facebook.com/share.php?u=#{href(article)}"
  end

  def twitter_share_href(article, length = nil, ellipsis='...')
    text = URI.encode("#{article.title} - Folioscope #{href(article)}")
    "https://twitter.com/intent/tweet?text=#{text}"
  end

  def hatena_share_href(article, length = nil, ellipsis='...')
    uri = URI.parse(href(article))
    origin = [80, 443].include?(uri.port) ? uri.host : "#{uri.host}:#{uri.port}"
    "http://b.hatena.ne.jp/entry/s/#{origin}#{uri.path}"
  end

  def href(article)
    URI.join(config[:endpoint], article.url).to_s
  end
end
