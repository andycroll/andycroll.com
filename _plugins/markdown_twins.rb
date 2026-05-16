require "fileutils"
require "nokogiri"
require "reverse_markdown"

module MarkdownTwins
  FRONT_MATTER_PATTERN = /\A---\s*\n.*?\n---\s*\n/m
  MARKDOWN_EXTS = %w[.md .markdown].freeze

  module_function

  def write(doc, site)
    return unless twinable?(doc)
    body = twin_body(doc)
    return if body.nil? || body.empty?
    output = compose(doc, site, body)
    dest_dir = File.join(site.dest, doc.url)
    FileUtils.mkdir_p(dest_dir)
    File.write(File.join(dest_dir, "index.md"), output)
  end

  def twinable?(doc)
    return false unless doc.url
    doc.url.end_with?("/") || doc.url.end_with?(".html")
  end

  def twin_body(doc)
    body =
      if MARKDOWN_EXTS.include?(doc.extname.to_s.downcase)
        File.read(doc.path, mode: "r:UTF-8").sub(FRONT_MATTER_PATTERN, "")
      else
        html_main_to_markdown(doc.output.to_s)
      end
    return nil if body.nil?
    normalized = body.gsub("&nbsp;", " ").tr("\u00A0", " ").strip
    normalized.empty? ? nil : normalized
  end

  def html_main_to_markdown(html)
    return nil if html.empty?
    node = Nokogiri::HTML(html).at_css("[role=main]")
    return nil unless node
    ReverseMarkdown.convert(node.inner_html, unknown_tags: :bypass)
  end

  def compose(doc, site, body)
    title = doc.data["title"].to_s.strip
    description = doc.data["description"].to_s.strip
    canonical = "#{site.config["url"]}#{doc.url}"

    parts = []
    parts << "# #{title}" unless title.empty?
    parts << "> #{description}" unless description.empty?
    if doc.respond_to?(:date) && doc.date && doc.is_a?(Jekyll::Document)
      parts << "*Published #{doc.date.strftime("%Y-%m-%d")} — <#{canonical}>*"
    else
      parts << "*<#{canonical}>*"
    end
    parts << "---"
    parts << body
    parts.join("\n\n") + "\n"
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  site.posts.docs.each { |doc| MarkdownTwins.write(doc, site) }
  site.pages.each { |page| MarkdownTwins.write(page, site) }
end
