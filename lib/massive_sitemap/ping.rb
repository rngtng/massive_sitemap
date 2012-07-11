# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require 'cgi'
require 'open-uri'

# Ping Search Engines to pull the latest update
module MassiveSitemap
  ENGINES_URLS = {
    :google => 'http://www.google.com/webmasters/tools/ping?sitemap=%s',
    :bing   => 'http://www.bing.com/webmaster/ping.aspx?siteMap=%s',
    :ask    => 'http://submissions.ask.com/ping?sitemap=%s',
  }

  def ping(url, engines = ENGINES_URLS.keys)
    url =  verify_and_escape(url)

    Array(engines).each do |engine|
      if engine_url = ENGINES_URLS[engine]
        begin
          open(engine_url % url)
        rescue SocketError
        end
      end
    end
  end
  module_function :ping

  private
  def verify_and_escape(url)
    schema, host, path = url.scan(/^(https?:\/\/)?(.+?)(\/.+)$/).flatten
    raise URI::InvalidURIError, url if path.to_s.empty?
    CGI::escape("#{schema || 'http://'}#{host}#{path}")
  end
  module_function :verify_and_escape
end
