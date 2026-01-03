# frozen_string_literal: true

require "tty-progressbar"
require "uri"

module Rokujo
  module Extractor
    module Filters
      # A filter to remove URLs from sentences.
      class UrlRemover < Base
        def call(sentences, bar = nil)
          bar&.configure { |config| config.total = sentences.count * 512 }

          pattern = URI::DEFAULT_PARSER.make_regexp(%w[http https ftp ftps file])
          results = sentences.map do |sentence|
            result = sentence.sub(pattern, "")
            bar&.advance(512)
            result
          end
          bar&.finish
          results
        end

        def widget
          widget_bar
        end
      end
    end
  end
end
