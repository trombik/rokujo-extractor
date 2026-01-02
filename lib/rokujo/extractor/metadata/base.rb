# frozen_string_literal: true

require "json"

module Rokujo
  module Extractor
    module Metadata
      # The base class for Metadata.
      class Base
        include Rokujo::Extractor::Errors
        include Rokujo::Extractor::Concerns::Identifiable

        attr_reader :opts, :location

        # These attributes are expected to be impplemented in subclasses.
        ABSTARCT_ATTRIBUTES = %w[
          title
          author
          uri
          created_at
          updated_at
          acquired_at
        ].map(&:to_sym).freeze

        # These attributes are provided by this class.
        CONCRETE_ATTRIBUTES = %w[
          type
          uuid
        ].map(&:to_sym).freeze

        # Mandatory attributes.
        CORE_ATTRIBUTES = (ABSTARCT_ATTRIBUTES + CONCRETE_ATTRIBUTES).freeze

        # @param location [String] The location of the resource.
        # @param ops [Hash] Optional options.
        def initialize(location, opts = {})
          @location = Pathname.new(location)
          @opts = opts
        end

        # The file type.
        def type
          self.class.name.split("Metadata::").last
        end

        # The title, e.g., the content of <title> tag in HTML.
        def title
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The author of the resource. Not necessarily an individual, e.g., an
        # organization.
        def author
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The URI of the resource.
        def uri
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The ISO 8601 timestamp of when the resource was created.
        def created_at
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The ISO 8601 timestamp of when the resource was updated.
        def updated_at
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        # The ISO 8601 timestamp of when the resource was acquired.
        def acquired_at
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        def uuid
          @uuid ||= uuid_v7
        end

        # Returns metadata as a Hash
        def to_h
          {
            core: core_attributes,
            extra: extra_attributes
          }
        end

        alias attributes to_h

        # Returns metadata as a JSON string.
        #
        # @param args [Array] Optional argument for `JSON#generate`.
        def to_json(*args)
          JSON.generate(to_h, *args)
        end

        private

        def core_attributes
          hash = {}
          CORE_ATTRIBUTES.each do |attr|
            value = send(attr)
            hash[attr] = value.nil? ? "" : value
          end
          hash
        end

        # Optional attributes subclass provides.
        def extra_attributes
          {}
        end
      end
    end
  end
end
