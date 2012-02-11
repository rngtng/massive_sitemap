# require 'uri'
# require 'fileutils'

require "massive_sitemap/version"

require 'massive_sitemap/writer/file'
require 'massive_sitemap/builder/rotating'
require 'massive_sitemap/builder/index'

# Page at -> <base_url>
# http://example.de/dir/

# Index at
# http://sitemap.example.de/index-dir/

# Save at -> <document_full>
# /root/dir/ ->  <document_root>/<document_path>

module MassiveSitemap
  DEFAULTS = {
    # builder
    :base_url               => nil,
    :indent_by              => 2,

    # writer
    :document_full          => '.',
    :force_overwrite        => false,
    :filename               => "sitemap.xml",
    :index_filename         => "sitemap_index.xml",

    # writer
    :writer                 => MassiveSitemap::Writer::File,
  }

  def generate(options = {}, &block)
    @options = DEFAULTS.merge options

    unless @options[:base_url]
      raise ArgumentError, 'you must specify ":base_url" string'
    end
    @options[:index_base_url] ||= @options[:base_url]

    Dir.mkdir(@options[:document_full]) unless ::File.exists?(@options[:document_full])

    @writer = @options[:writer].new @options

    generate_sitemap(&block)
  end
  module_function :generate

  def generate_sitemap(&block)
    @builder = Builder::Rotating.new(@writer, @options)
    instance_eval(&block) if block
    @builder.close!
    self
  end
  module_function :generate_sitemap

  # Create a sitemap index document
  def generate_index(files = nil)
    files ||= Dir[File.join(@options[:document_full], "*.{xml,xml.gz}")]

    @writer.options.merge!(:filename => @options[:index_filename], :force_overwrite => true)
    Builder::Index.new(@writer, @options) do
      files.each do |path|
        next if path.include?(@options[:index_filename])
        add ::File.basename(path), :last_modified => File.stat(path).mtime
      end
    end
    self
  end
  module_function :generate_index

  def add(path, attrs = {})
    @builder.add(path, attrs)
  end
  module_function :add
end
