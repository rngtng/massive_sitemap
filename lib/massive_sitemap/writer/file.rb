# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require 'fileutils'
require 'massive_sitemap/writer/base'

# MassiveSitemap Writer File
# Extension to base writer for writing into file(s).

module MassiveSitemap
  module Writer
    class File < Base

      class FileExistsException < IOError; end

      OPTS = Base::OPTS.merge(
        :root            => '.',
        :force_overwrite => false,
        :filename        => "sitemap.xml",
      )

      def initialize(options = {})
        super
        init_stream_ids
      end

      protected
      def open_stream
        #create dir if not exists
        @stream_id = filename
        ::File.dirname(tmp_filename).tap do |dir|
          FileUtils.mkdir_p(dir) unless ::File.exists?(dir)
        end
        ::File.open(tmp_filename, 'wb')
      end

      def close_stream(file)
        file.close
        # Move from tmp_file into acutal file
        ::File.delete(filename) if ::File.exists?(filename)
        ::File.rename(tmp_filename, filename)
        add_stream_id(filename)
        rotate
      end

      def init?
        if !@options[:force_overwrite] && find_stream_id(filename)
          error_message = "Can not create file: #{filename} exits"
          rotate #push next possible filename
          raise FileExistsException, error_message
        end
        true
      end

      # Keep state of Files
      def init_stream_ids
        @stream_ids = {}
        load_stream_ids

        if @options[:partial_update]
          delete_stream_ids upper_stream_ids(@stream_ids.keys)
        end

        if (keep_file_for = @options[:keep_file_for].to_i) > 0
          delete_stream_ids chaos_monkey_stream_ids(@stream_ids.keys.sort, keep_file_for)
        end
      end

      def load_stream_ids
        Dir[::File.join(@options[:root], "*#{::File.extname(filename)}")].each do |path|
          add_stream_id(path, ::File.stat(path).mtime)
        end
      end

      def upper_stream_ids(stream_id_keys)
        {}.tap do |cluster|
          stream_id_keys.each do |path|
            filename, rotation,  ext = split_filename(path)
            _,        rotation2, _   = split_filename(cluster[filename])
            if rotation.to_i >= rotation2.to_i
              cluster[filename] = path
            end
          end
        end.values
      end

      def chaos_monkey_stream_ids(stream_id_keys, days)
        return [] if days < 1
        offset = 1 + Time.now.to_i / (24 * 60 * 60)
        stream_id_keys.select do |stream_id_key|
          (stream_id_key.scan(/\d+/).first.to_i + offset) % days == 0
        end
      end

      def delete_stream_ids(to_delete)
        @stream_ids.delete_if { |key, value| to_delete.include?(key) }
      end

      def find_stream_id(path)
        @stream_ids.keys.include?(::File.basename(path))
      end

      def add_stream_id(path, last_modified = Time.now)
        @stream_ids[::File.basename(path)] = last_modified
      end

      def stream_id
        @stream_id && ::File.basename(@stream_id)
      end

      private
      def filename
        ::File.join @options[:root], @options[:filename]
      end

      def tmp_filename
        filename + ".tmp"
      end

      def rotate
        @options[:filename] = with_rotation(@options[:filename])
      end

      def with_rotation(filename)
        filename, rotation, ext = split_filename(filename)
        [filename, "-", rotation.to_i + 1, ext].join
      end

      def split_filename(filename)
        filename.to_s.scan(/^([^.]*?)(?:-([0-9]+))?(\..+)?$/).flatten
      end

    end

  end
end
