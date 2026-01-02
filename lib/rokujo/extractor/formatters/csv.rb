# frozen_string_literal: true

require "csv"

module Rokujo
  module Extractor
    module Formatters
      # A formatter for CSV output.
      class CSV < Base
        def call(sentences, bar = nil)
          bar&.configure { |config| config.total = sentences.count }
          result = ::CSV.generate(converters: :integer) do |csv|
            sentences.each do |sentence|
              csv << [
                sentence[:text],
                sentence[:meta][:line_number],
                sentence[:meta][:uuid]
              ]
            end
            bar&.advance
          end
          bar&.finish
          result
        end

        def widget
          ::TTY::ProgressBar.new("#{base_class_name} [:bar]")
        end
      end
    end
  end
end
