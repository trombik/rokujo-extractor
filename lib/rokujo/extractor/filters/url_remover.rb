# frozen_string_literal: true

require "tty-progressbar"
require "uri"

module Rokujo
  module Extractor
    module Filters
      # A filter to remove URLs from sentences.
      class UrlRemover
        def call(sentences, bar = nil)
          bar&.configure { |config| config.total = sentences.count }

          pattern = URI::DEFAULT_PARSER.make_regexp(%w[http https ftp ftps file])
          results = sentences.map do |sentence|
            sentence.sub(pattern, "")
          end
          bar&.finish
          results
        end

        def widget
          ::TTY::ProgressBar.new("#{base_class_name} [:bar]")
        end

        private

        def base_class_name
          self.class.name.split("::").last
        end
      end
    end
  end
end
