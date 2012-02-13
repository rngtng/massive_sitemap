require 'uri'
require 'fileutils'

require 'massive_sitemap/builder/rotating'
require 'massive_sitemap'

class BigSitemap
  DEFAULTS = {
    :max_per_sitemap => MassiveSitemap::Builder::Rotating::NUM_URLS.max,
    :batch_size      => 1001, # TODO: Deprecate
    :document_path   => '/',
    :gzip            => true,

    # Opinionated
    :ping_google => true,
    :ping_yahoo  => false, # needs :yahoo_app_id
    :ping_bing   => false,
    :ping_ask    => false
  }

  def self.generate(options={}, &block)
    BigSitemap.new(options, &block)
  end

  def initialize(options={}, &block)
    @options = DEFAULTS.merge options

    if @options[:max_per_sitemap] <= 1
      raise ArgumentError, '":max_per_sitemap" must be greater than 1'
    end

    if @options[:url_options] && !@options[:base_url]
      @options[:base_url] = URI::Generic.build( {:scheme => "http"}.merge(@options.delete(:url_options)) ).to_s
    end

    unless @options[:base_url]
      raise ArgumentError, 'you must specify either ":url_options" hash or ":base_url" string'
    end
    @options[:url_path] ||= @options[:document_path]

    unless @options[:document_root]
      raise ArgumentError, 'Document root must be specified with the ":document_root" option"'
    end

    @options[:document_full] ||= File.join(@options[:document_root], @options[:document_path])
    unless @options[:document_full]
      raise ArgumentError, 'Document root must be specified with the ":document_root" option, the full path with ":document_full"'
    end

    Dir.mkdir(@options[:document_full]) unless File.exists?(@options[:document_full])

    @options[:url]  = @options[:base_url]
    @options[:root] = @options[:document_full]
    MassiveSitemap.generate(@options, &block)
  end

  def with_lock(&block)
    MassiveSitemap.lock!(&block)
  end

  def generate_sitemap_index(files=nil)
    # TODO
  end

  def dir_files
    File.join(@options[:root], "sitemap*.{xml,xml.gz}")
  end

  def clean
    Dir[dir_files].each do |file|
      FileUtils.rm file
    end
    self
  end
end
