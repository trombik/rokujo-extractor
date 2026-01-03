# frozen_string_literal: true

require "pastel"

module Rokujo
  module Extractor
    module Filters
      # The base class for Filters.
      class Base
        def initialize; end

        # The default progress bar
        def widget_bar
          ::TTY::ProgressBar.new(
            format("%-40s [:bar] [:elapsed]", pastel.cyan(base_class_name)),
            head: pastel.green(">"),
            complete: pastel.green("=")
          )
        end

        private

        # The name of the filter
        def base_class_name
          self.class.name.split("Extractor::").last
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
