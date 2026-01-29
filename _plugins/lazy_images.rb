require "nokogiri"

Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  next unless doc.output_ext == ".html"

  # Use regex to add loading="lazy" to img tags that don't have it
  # This preserves the original document structure unlike Nokogiri parsing
  doc.output = doc.output.gsub(/<img\s+(?![^>]*loading=)(?![^>]*data-no-lazy)/i) do |match|
    if match =~ /src=["'][^"']*\.svg/i
      match  # Skip SVG images
    else
      match.sub(/<img\s+/i, '<img loading="lazy" ')
    end
  end
end
