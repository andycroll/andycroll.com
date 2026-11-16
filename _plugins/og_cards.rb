require "digest"
require "json"

# Share cards: every post and page at a directory URL gets `og_image`, the path
# of its 1200x630 card, /og/<url>-<fingerprint>.jpg ("/" is /og/index-...), which
# head.html uses for og:image. Opt a page out with `og_card: false`.
#
# The fingerprint covers everything the card is drawn from: its text, date,
# pictures and the files every card uses. It changes exactly when the card
# would look different, so link previews refresh then and only then, and
# bin/og-cards reuses its earlier drawing of any card whose fingerprint it has.
#
# With OG_CARDS set, the build also renders each card as a page at
# /og-cards/<url>-<fingerprint>/ (layout og_card.html). bin/og-cards screenshots
# those into _site/og/ and removes them; the deploy workflow runs both.
module OgCards
  # Files every card is drawn with: a change to any of them redraws every card.
  SHARED_FILES = %w[
    _layouts/og_card.html
    assets/css/app.css
    assets/css/custom.css
    fonts/merriweather-regular-webfont.woff2
    images/andycroll.svg
    images/andycroll.jpg
    images/onerubything-horizontal.svg
    images/uses.svg
  ].freeze

  class Generator < Jekyll::Generator
    priority :lowest # after Uses::Generator sets each thing's section and image kind

    def generate(site)
      @site = site
      @digests = {}
      shared = SHARED_FILES.map { |path| digest(path) } << site.config["description"]

      docs = site.posts.docs + site.pages.select { |page| page.html? && page.url.end_with?("/") }
      docs.each do |doc|
        next if doc.data["og_card"] == false || doc.data.key?("redirect") || !doc.data["layout"]

        data = card_data(doc)
        fingerprint = Digest::SHA256.hexdigest(JSON.generate([shared, data, pictures(data)]))[0, 12]
        path = "#{doc.url == "/" ? "/index" : doc.url.chomp("/")}-#{fingerprint}"
        doc.data["og_image"] = "/og#{path}.jpg"
        site.pages << card_page(path, data) if ENV["OG_CARDS"]
      end
    end

    private

    def card_data(doc)
      {
        "title" => doc.data["title"],
        "description" => doc.data["description"],
        "image" => doc.data["image"],
        "card_url" => doc.url,
        "card_kind" => kind(doc),
        "card_section" => doc.data["uses_section"],
        "card_date" => (doc.date.to_date.to_s if doc.is_a?(Jekyll::Document))
      }
    end

    # The files the card shows: the hero, or a /uses/ page's first pictures
    # (the same selection as og_card.html).
    def pictures(data)
      if data["card_kind"] == "uses"
        items = @site.collections["uses"].docs.select { |item| !item.data["retired"] && item.data["image"] }
        items = items.select { |item| item.data["section"] == data["card_section"] } if data["card_section"]
        items.first(data["card_section"] ? 4 : 6).map do |item|
          image = item.data["image"]
          digest("images/#{image["base"]}.#{image["kind"] == "icon" ? "png" : "jpg"}")
        end
      elsif data.dig("image", "base")
        [digest("images/#{data["image"]["base"]}.jpg")]
      else
        []
      end
    end

    def digest(path)
      @digests[path] ||= begin
        file = @site.in_source_dir(path)
        File.file?(file) ? Digest::SHA256.file(file).hexdigest : "missing"
      end
    end

    def card_page(path, data)
      card = Jekyll::PageWithoutAFile.new(@site, @site.source, "og-cards#{path}", "index.html")
      card.data.merge!(data, "layout" => "og_card", "sitemap" => false, "og_card" => false)
      card
    end

    def kind(doc)
      return "home" if doc.url == "/"
      return "uses" if doc.data["layout"] == "uses"
      return "ruby" if doc.url.start_with?("/ruby/") # posts and the One Ruby Thing index

      "page"
    end
  end
end
