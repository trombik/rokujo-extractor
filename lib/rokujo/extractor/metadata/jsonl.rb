# frozen_string_literal: true

require "pathname"
require "uri"

require_relative "base"

module Rokujo
  module Extractor
    module Metadata
      # Metadata for JSONL file on local file system.
      class JSONL < Base
        def title
          ""
        end

        def author
          ""
        end

        def uri
          URI::File.build([nil, Pathname.new(@location).realpath.to_s])
        end

        def created_at
          ""
        end

        def updated_at
          ""
        end

        def acquired_at
          @acquired_at ||= Time.now.utc.iso8601
        end

        private

        def info
          ""
        end

        def doc
          ""
        end

        def extra_attributes
          {}
        end
      end
    end
  end
end
