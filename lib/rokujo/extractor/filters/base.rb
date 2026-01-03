# frozen_string_literal: true

require_relative "../concerns"

module Rokujo
  module Extractor
    module Filters
      # The base class for Filters.
      class Base
        include Rokujo::Extractor::Concerns::Renderable
      end
    end
  end
end
