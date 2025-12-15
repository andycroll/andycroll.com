require "nokogiri"

Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  next unless doc.output_ext == ".html"

  parsed = Nokogiri::HTML::DocumentFragment.parse(doc.output)

  parsed.css("img").each do |img|
    next if img["loading"]
    next if img["src"]&.match?(/\.svg($|\?)/i)
    next if img["data-no-lazy"]

    img["loading"] = "lazy"
  end

  doc.output = parsed.to_html
end
