
module MassiveSitemap
  module Writer
    class Base
      OPTS = {}

      attr_reader :options

      def initialize(options = {})
        @options = self.class::OPTS.merge(options)
        @stream  = nil
      end

      # Interface
      def open_stream
        @string ||= StringIO.new
      end

      def close_stream(stream)
      end

      def init?
        true
      end

      def streams
        []
      end

      # API
      def init!(options = {})
        close!
        @options.merge!(options)
        if init?
          @stream = open_stream
        end
      end

      def close!
        if inited?
          close_stream(@stream)
          @stream = nil
        end
      end

      def inited?
        @stream
      end

      def print(string)
        @stream.print(string) if inited?
      end

      def each(&block)
        streams.each(&block)
      end
    end

  end
end