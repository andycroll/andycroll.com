# Puts /now/ in the feeds as `site.data.now_updates`: one entry, dated by the
# page's `last_modified_at` or `date`, with an id that changes with that date so
# each rewrite reaches subscribers as a new entry.
module NowInFeed
  class Generator < Jekyll::Generator
    priority :low

    def generate(site)
      page = site.pages.find { |p| p.url == "/now/" }
      time = page && (page.data["last_modified_at"] || page.data["date"])
      site.data["now_updates"] = []
      return unless time

      time = Jekyll::Utils.parse_date(time.to_s)
      return if time > site.time && !site.future

      site.data["now_updates"] << {
        "title" => "#{page.data["title"]}, #{time.strftime("%-d %B %Y")}",
        "url" => page.url,
        "id" => "#{page.url}##{time.to_date}",
        "date" => time,
        "content" => site.find_converter_instance(Jekyll::Converters::Markdown).convert(page.content)
      }
    end
  end
end
