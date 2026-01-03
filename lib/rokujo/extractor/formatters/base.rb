# frozen_string_literal: true

require "tty-spinner"

module Rokujo
  module Extractor
    module Formatters
      # The base class for Formatters that implements common methods.
      class Base
        include Rokujo::Extractor::Concerns::Renderable

        # The method the pipeline calls. Mandatory to implement.
        #
        # @param sentences [Array<String>] Array of sentences to process.
        # @param widget [Object] The instance of `#widget`. As `widget` can be
        #                        nil, append `&` before method call.
        #                        e.g., `bar&.advance`. The caller may disable
        #                        TUI widgets to silence the output.
        # @return [String] The formatted String.
        def call(sentences, widget = nil)
          raise NotImplementedError, "Subclasses must implement call method"
        end
      end
    end
  end
end
