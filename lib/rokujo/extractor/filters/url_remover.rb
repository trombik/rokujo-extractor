# frozen_string_literal: true

require "tty-progressbar"
require "uri"

module Rokujo
  module Extractor
    module Filters
      # A filter to remove URLs from sentences.
      #
      # rubocop:disable Metrics/MethodLength
      class UrlRemover < Base
        def call(sentences, widget_enable: true)
          self.widget_enable = widget_enable
          with_progress(total: sentences.count * 512) do |bar|
            pattern = URI::DEFAULT_PARSER.make_regexp(%w[http https ftp ftps file])
            results = sentences.map do |sentence|
              result = sentence.sub(pattern, "")
              bar.advance(512)
              result
            end
            bar.finish
            results
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
