# frozen_string_literal: true

require_relative "file_item"

module Rokujo
  module Extractor
    module Items
      # ArticleItem for PDF files
      class DocxItem < FileItem
        def initialize(location, opts = {})
          super
        end

        def acquired_time
          Time.now.utc.iso8601
        end

        def author
          core_xml_doc.xpath("//creator").text
        end

        def description
          core_xml_doc.xpath("//description").text
        end

        def kind
          "document"
        end

        def modified_time
          core_xml_doc.xpath("//modified").text
        end

        def published_time
          core_xml_doc.xpath("//created").text
        end

        def site_name; end

        def title
          core_xml_doc.xpath("//title").text
        end

        def url; end

        # FileItem specific
        # source
        def source
          @source ||= {}
        end

        private

        def core_xml_doc
          return @core_xml_doc if @core_xml_doc

          Zip::File.open(location.to_s) do |zip|
            @core_xml_doc = Nokogiri::XML(zip.read("docProps/core.xml")).remove_namespaces!
          end
          @core_xml_doc
        rescue e
          warn "Failed to process file: #{location}"
          raise e
        end
      end
    end
  end
end
