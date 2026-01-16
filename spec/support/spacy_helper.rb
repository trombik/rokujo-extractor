# frozen_string_literal: true

# Cache model and reuse it in all the examples
module SpacyHelper
  def model
    SpacyHelper.spacy_model
  end

  # keep model in class instance variable, avoiding global variable
  def self.spacy_model
    @spacy_model ||= Spacy::Language.new(Rokujo::Extractor::Parsers::Base::DEFAULT_SPACY_MODEL_NAME)
  end
end
