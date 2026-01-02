# frozen_string_literal: true

require "tty-spinner"

module Rokujo
  module Extractor
    module Formatters
      # The base class for Formatters that implements common methods.
      class Base
        # The widget the class supports. Default is spinner.
        #
        # Use `TTY::ProgressBar.new("#{base_class_name} [:bar]")` if the
        # number of stpes is known.
        def widget
          ::TTY::Spinner.new("[:spinner] #{base_class_name} Processing ... ")
        end

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

        private

        # Returns the last part of the class name.
        def base_class_name
          self.class.name.split("::").last
        end
      end
    end
  end
end
