module Jekyll
  # Sass plugin to convert .scss to .css
  #
  # Note: This is configured to use the new css like syntax available in sass.
  require 'sass'
  class SassConverter < Converter
    safe true
    # priority :low

    def matches(ext)
      ext =~ /scss/i
    end

    def output_ext(ext)
      ".css"
    end

    def convert(content)
      puts "Performing Sass Conversion."
      # puts self.dir
      engine = Sass::Engine.new(content, {:syntax => :scss, :style => :compressed, :template_location => ['.', File.join('.', 'stylesheets')]})
      engine.render
    rescue StandardError => e
      puts "!!! SASS Error: " + e.message
    end
  end
end
