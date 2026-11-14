# Things I use live in _uses/<section>/<thing>.md and render on /uses/<section>/.
# Like posts, a thing can be dated by its filename (2026-11-20-comandante-c40.md)
# or a `date`, and edits are marked with `last_modified_at`. `retired` has no
# Jekyll equivalent: it moves the thing to "No longer using".
#
# This generator gives each thing a `section` (its folder name) for the layout,
# and turns those three dates into `site.data.uses_updates`: one entry per
# change, newest first, listed on /uses/ and merged into the feeds. Each entry
# has the keys the feeds read from posts (title, url, id, date, content), with
# url pointing at the thing on its section page. Undated things produce no
# "New" entry, so the list I launch with doesn't flood the feed.
module Uses
  class Generator < Jekyll::Generator
    priority :low

    KINDS = {
      "date" => "New in",
      "last_modified_at" => "Updated in",
      "retired" => "Removed from"
    }.freeze

    def generate(site)
      sections = site.pages.select { |page| page.data["uses_section"] }
        .to_h { |page| [page.data["uses_section"], page] }
      markdown = site.find_converter_instance(Jekyll::Converters::Markdown)

      updates = site.collections["uses"].docs.flat_map do |item|
        item.data["section"] = File.basename(File.dirname(item.relative_path))
        section = sections.fetch(item.data["section"])

        # Read data directly: Document#date falls back to the build time.
        KINDS.keys.filter_map do |field|
          time = to_time(item.data[field])
          next unless time
          next if time > site.time && !site.future

          update(item, field, time, section, markdown)
        end
      end

      site.data["uses_updates"] = updates.sort_by { |entry| entry["date"] }.reverse
    end

    private

    # Dates arrive as Date, Time, or String depending on how they're written.
    def to_time(value)
      return if value.nil?
      return value if value.is_a?(Time)

      Jekyll::Utils.parse_date(value.is_a?(Date) ? "#{value} 09:00" : value.to_s)
    end

    def update(item, field, time, section, markdown)
      label = "#{KINDS[field]} #{section.data["title"]}"
      url = "#{section.url}##{item.data["slug"]}"

      {
        "label" => label,
        "name" => item.data["title"],
        "title" => "#{label}: #{item.data["title"]}",
        "url" => url,
        "id" => "#{url}-#{field}-#{time.to_date}",
        "date" => time,
        "content" => markdown.convert(item.content)
      }
    end
  end
end
