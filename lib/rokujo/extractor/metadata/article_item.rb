# frozen_string_literal: true

require "json"

require_relative "base"

module Rokujo
  module Extractor
    module Metadata
      # Metadata for ArticleItem.
      class ArticleItem < Base
        attr_reader :json

        def initialize(json_string, uuid, opts = {})
          # as the metadata comes from json_string, pass an empty string for
          # location.
          super("", opts)
          @uuid = uuid
          @json = JSON.parse(json_string)
        end

        def title
          json["title"]
        end

        def author
          json["author"]
        end

        def uri
          json["url"]
        end

        def created_at
          json["published_time"]
        end

        def updated_at
          json["modified_time"]
        end

        def acquired_at
          json["acquired_time"]
        end

        def extra_attributes
          {
            description: json["description"],
            site_name: json["site_name"],
            kind: json["kind"],
            uuid: @uuid
          }
        end
      end
    end
  end
end
