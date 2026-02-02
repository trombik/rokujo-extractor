# frozen_string_literal: true

require_relative "file_item"
require "pdf-reader"

module Rokujo
  module Extractor
    module Items
      # ArticleItem for PDF files
      class PdfItem < FileItem
        def initialize(location, opts = {})
          super
        end

        def acquired_time
          info[:AcquiredTime] || Time.now.utc.iso8601
        end

        def author
          info[:Author]
        end

        def description
          info[:SourceDescription] || ""
        end

        def kind
          "document"
        end

        def modified_time
          asn1_time_to_time_string(info[:ModDate])
        end

        def published_time
          asn1_time_to_time_string(info[:CreationDate])
        end

        def site_name
          info[:SourceSiteName]
        end

        def title
          info[:Title]
        end

        def url
          info[:FileURL] || super
        end

        # FileItem specific
        def filename
          info[:OriginalFilename] || super
        end

        # source
        def source
          @source ||= {
            title: info[:SourceTitle],
            url: info[:SourceURL],
            site_name: info[:SourceSiteName],
            description: info[:SourceDescription]
          }
        end

        private

        def asn1_time_to_time_string(str)
          return unless str

          time_string = str.sub(/^D:/, "")
                           .sub("'", "")
          Time.strptime(time_string, "%Y%m%d%H%M%S%z").utc.iso8601
        end

        def info
          @info ||= doc.info
        end

        def doc
          @doc ||= ::PDF::Reader.new(@location)
        end
      end
    end
  end
end
