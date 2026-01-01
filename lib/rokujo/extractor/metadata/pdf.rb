# frozen_string_literal: true

require "pathname"
require "uri"
require "time"

module Rokujo
  module Extractor
    module Metadata
      # Metadata for PDF file on local file system.
      class PDF < Base
        def initialize(location, opts = {})
          doc
          super
        end

        def title
          doc.info[:Title]
        end

        def author
          doc.info[:Author]
        end

        def uri
          URI::File.build([nil, Pathname.new(location).realpath])
        end

        def created_at
          doc.info[:CreationDate]
        end

        def updated_at
          doc.info[:ModDate]
        end

        attr_reader :acquired_at

        private

        def info
          doc.info
        end

        def doc
          @doc ||= ::PDF::Reader.new(location)
          @acquired_at = Time.now.utc.iso8601
        end

        def extra_attributes
          {
            Producer: doc.info[:Producer]
          }
        end
      end
    end
  end
end
