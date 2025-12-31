# frozen_string_literal: true

require "uri"
require "time"
require "pathname"

module Rokujo
  module Extractor
    module Metadata
      # Metadata for text file on local file system.
      class Text < Base
        attr_reader :acquired_at, :location

        include Rokujo::Extractor::Concerns::Identifiable
        include Rokujo::Extractor::Concerns::SystemSpecific

        def initialize(location, opts = {})
          super
          @location = Pathname.new(location)
          doc
        end

        def title
          location.basename(".*").to_s
        end

        def author
          nil
        end

        def uri
          URI::File.build([nil, location.realpath]).to_s
        end

        def created_at
          on_os_type(
            windows: -> { File.stat(location).ctime },
            default: -> { File.stat(location).birthtime }
          )
        rescue NotImplementedError
          updated_at
        end

        def updated_at
          File.stat(location).mtime
        end

        def to_h; end

        private

        def doc
          @doc ||= ::File.read(location)
          @acquired_at = Time.now.utc.iso8601
        end
      end
    end
  end
end
