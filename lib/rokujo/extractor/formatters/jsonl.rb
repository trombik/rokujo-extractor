# frozen_string_literal: true

require "json"

module Rokujo
  module Extractor
    module Formatters
      # A formatter for JSONL output.
      class JSONL < Base
        def call(sentences, bar = nil)
          bar&.configure { |config| config.total = sentences.count }
          result = sentences.map do |sentence|
            json = sentence.to_json
            bar&.advance
            json
          end
          bar&.finish
          result.join("\n")
        end

        def widget
          ::TTY::ProgressBar.new("#{base_class_name} [:bar]")
        end
      end
    end
  end
end
