# Share cards: every post and page at a directory URL gets `og_image`, the path
# of its 1200x630 card, /og/<url>.jpg ("/" is /og/index.jpg), which head.html
# uses for og:image. Opt a page out with `og_card: false`.
#
# With OG_CARDS set, the build also renders each card as a page at
# /og-cards/<url>/ (layout og_card.html). bin/og-cards screenshots those into
# _site/og/ and removes them; the deploy workflow runs both.
module OgCards
  class Generator < Jekyll::Generator
    priority :lowest

    def generate(site)
      docs = site.posts.docs + site.pages.select { |page| page.html? && page.url.end_with?("/") }
      docs.each do |doc|
        next if doc.data["og_card"] == false || doc.data.key?("redirect") || !doc.data["layout"]

        path = doc.url == "/" ? "/index" : doc.url.chomp("/")
        doc.data["og_image"] = "/og#{path}.jpg"
        site.pages << card_page(site, doc) if ENV["OG_CARDS"]
      end
    end

    private

    def card_page(site, doc)
      card = Jekyll::PageWithoutAFile.new(site, site.source, "og-cards#{doc.url}", "index.html")
      card.data.merge!(
        "layout" => "og_card",
        "sitemap" => false,
        "og_card" => false,
        "title" => doc.data["title"],
        "description" => doc.data["description"],
        "image" => doc.data["image"],
        "card_url" => doc.url,
        "card_kind" => kind(doc),
        "uses_section" => nil,
        "card_section" => doc.data["uses_section"],
        "card_date" => (doc.date if doc.is_a?(Jekyll::Document))
      )
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
