# frozen_string_literal: true

module Rokujo
  module Extractor
    module Concerns
      # A concern for classes to run system specific blocks
      module SystemSpecific
        OS_TYPE = case RbConfig::CONFIG["host_os"]
                  when /linux/ then :linux
                  when /bsd/ then :bsd
                  when /mswin|msys|mingw|cygwin/ then :windows
                  when /darwin/ then :macos
                  end

        # Selects and executes OS-specific behavior based on the current operating system.
        #
        # See `OS_TYPE` for supported OSes.
        #
        # @param map [Hash{Symbol => Object}] A hash where:
        #   - Keys are OS type symbols (:linux, :windows, :bsd, etc.)
        #   - Values can be either:
        #     * A values to return when OS matches
        #     * Callable objects (Proc/Lambda) to execute when OS matches
        #   - Special keys:
        #     - :default: Fallback value/callable when no OS matches (optional)
        #
        # @return [Object] Either:
        #   - The return value of the matched callable
        #   - The matched value
        #
        # @example Executing OS-specific code blocks
        #   on_os_type(
        #     linux: -> { configure_linux },
        #     windows: -> { configure_windows },
        #     default: -> { configure_generic }
        #   )
        #
        # @example Handling unknown OS
        #   on_os_type(
        #     linux: -> { "Linux" },
        #     default: -> { raise "Unsupported OS: #{OS_TYPE || 'unknown'}" }
        #   )
        def on_os_type(map)
          value = map[OS_TYPE] || map[:default]
          value.respond_to?(:call) ? value.call : value
        end
      end
    end
  end
end
