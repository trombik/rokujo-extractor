# frozen_string_literal: true

require "tty-spinner"

module Rokujo
  module Extractor
    module Formatters
      # The base class for Formatters that implements common methods.
      class Base
        # The widget the class supports. Default is spinner.
        #
        # Use `#widget_bar` if the number of stpes is known.
        def widget
          widget_spinner
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
          self.class.name.split("Extractor::").last
        end

        # The default progress bar
        def widget_bar(name = base_class_name.to_s)
          ::TTY::ProgressBar.new(
            format("%-40s [:bar] [:elapsed]", pastel.cyan(name)),
            head: pastel.green(">"),
            complete: pastel.green("=")
          )
        end

        # The default spinner
        def widget_spinner
          ::TTY::Spinner.new("[:spinner] #{base_class_name} Processing ... ")
        end

        # An instance of Pastel.
        #
        # When STDERR is not a tty, color is disabled.
        def pastel
          @pastel ||= Pastel.new(enabled: $stderr.tty?)
        end
      end
    end
  end
end
