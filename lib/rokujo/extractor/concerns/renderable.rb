# frozen_string_literal: true

require "tty-spinner"
require "tty-progressbar"
require "pastel"

module Rokujo
  module Extractor
    # Helpers for Rokujo::Extractor
    module Concerns
      # A concern that implements common TUI widgets
      module Renderable
        attr_writer :widget_enable

        # @return [Boolean] Enable or disable widgets.
        def widget_enable
          return false if ENV["CI"]

          return @widget_enable unless @widget_enable.nil?

          $stderr.tty?
        end

        private

        # An instance of Pastel.
        #
        # When STDERR is not a tty, color is disabled.
        def pastel
          Pastel.new(enabled: $stderr.tty?)
        end

        # Display a spinner while processing a block.
        # @param opts [Hash] The options. Accepts options for {TTY::Spinner},
        #   such as `:interval`.
        # @option message [String] The message of the spinner. An example: `[:spinner] Processing ...`
        #   The default is colored class name and `:spinner`.
        # @option spinner [TTY::Spinner] Optional spinner object. Useful to manage multiple spinners with {TTY::Spinner::Multi}.
        # @option file [String] Optional file name. If specified, the spinner displays the base name of the file name.
        # @example
        #   with_spinner(message: "[:spinner] Doing something ...") do |spinner|
        #     do_something
        #     spinner.pause
        #     sleep
        #     spinner.resume
        #     do_something_else
        #   end
        #
        # @yieldparam spinner [TTY::Spinner] Yields the spinner instance to the
        #   block.
        #
        def with_spinner(**opts)
          message = opts.fetch(:message, widget_spinner_default_message)
          message += " #{opts[:file]}" if opts[:file]
          spinner = opts.fetch(:spinner,
                               ::TTY::Spinner.new(
                                 message,
                                 **opts,
                                 output: widget_output
                               ))
          spinner.auto_spin
          result = yield(spinner)
          spinner.success("Done")
          result
        rescue StandardError => e
          spinner&.error("Failed")
          raise e
        end

        def widget_spinner_default_message
          format("%-40s [:spinner]", pastel.cyan(class_basename))
        end

        def widget_output
          widget_enable ? $stderr : File.open(File::NULL, "w")
        end

        def widget_bar_default_message
          format("%-40s [:bar] [:elapsed]", pastel.cyan(class_basename))
        end

        # Display a progress bar while processing a block.
        #
        # @param opts [Hash] The options. Accepts options for {TTY::ProgressBar},
        # @option message [String] The message/format of the progress bar. An example: `[:bar] :percent`
        # @option progress_bar [TTY::ProgressBar] Optional progress bar object.
        #
        # @yieldparam bar [TTY::ProgressBar] The active progress bar object.
        #
        # @example
        #   with_progress(message: "Downloading [:bar]", total: 100) do |bar|
        #     items.each do |item|
        #       process(item)
        #       bar.advance(1)
        #     end
        #   end
        #
        def with_progress(**opts)
          message = opts.fetch(:message, widget_bar_default_message)
          bar = opts.fetch(:progress_bar,
                           ::TTY::ProgressBar.new(
                             message,
                             **opts,
                             output: widget_output
                           ))
          result = yield(bar)
          bar.finish
          result
        rescue StandardError => e
          bar&.stop
          raise e
        end

        # Returns the base name without Rokujo::Extractor prefix.
        # @return [String]
        def class_basename
          self.class.name.sub(/^Rokujo::Extractor::/, "")
        end
      end
    end
  end
end
