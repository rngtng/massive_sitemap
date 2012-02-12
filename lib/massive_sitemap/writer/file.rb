require 'fileutils'
require 'massive_sitemap/writer/base'

# Write into File

module MassiveSitemap
  module Writer
    class File < Base

      class FileExistsException < IOError; end

      OPTS = Base::OPTS.merge(
        :root            => '.',
        :force_overwrite => false,
        :filename        => "sitemap.xml",
        :index_filename  => "sitemap_index.xml",
      )

      def open_stream
        ::File.dirname(tmp_filename).tap do |dir|
          FileUtils.mkdir_p(dir) unless ::File.exists?(dir)
        end
        ::File.open(tmp_filename, 'w:ASCII-8BIT')
      end

      def close_stream(stream)
        stream.close
        # Move from tmp_file into acutal file
        ::File.delete(filename) if ::File.exists?(filename)
        ::File.rename(tmp_filename, filename)
      end

      def init?
        if !options[:force_overwrite] && ::File.exists?(filename)
          raise FileExistsException, "Can not create file: #{filename} exits"
        end
        true
      end

      def streams
        files.map do |path|
          next if path.include?(options[:index_filename])
          [::File.basename(path), ::File.stat(path).mtime]
        end.compact
      end

      private
      def filename
        ::File.join options[:root], options[:filename]
      end

      def tmp_filename
        filename + ".tmp"
      end

      def files
        Dir[::File.join(options[:root], "*.xml")]
      end
    end

  end
end
