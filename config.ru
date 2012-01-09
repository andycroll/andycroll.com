require 'bundler/setup'
require 'sinatra/base'

# The project root directory
$root = ::File.dirname(__FILE__)

require 'sass/plugin/rack'
use Sass::Plugin::Rack
Sass::Plugin.options[:syntax] = :scss
Sass::Plugin.options[:style] = :compress
Sass::Plugin.options[:css_location] = File.join(File.dirname(__FILE__), 'public', 'stylesheets')
Sass::Plugin.options[:template_location] = File.join(File.dirname(__FILE__), 'source', 'sass')

class SinatraStaticServer < Sinatra::Base

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_sinatra_file('404.html') {"Sorry, I cannot find #{request.path}"}
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end

run SinatraStaticServer