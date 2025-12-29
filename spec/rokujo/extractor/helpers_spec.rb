# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Helpers do
  include described_class

  describe Rokujo::Extractor::Helpers::NilSpinner do
    let(:spinner) { described_class.new }

    describe "#new" do
      it "does not raise error" do
        expect { spinner }.not_to raise_error
      end
    end

    describe "#method_missing" do
      it "does not raise when known method is given" do
        expect { spinner.auto_spin }.not_to raise_error
      end

      it "raise NoMethodError when unknown method is given" do
        expect { spinner.foo_bar }.to raise_error NoMethodError
      end
    end
  end

  describe "#while_spinning" do
    let(:spinner) { instance_double(TTY::Spinner) }

    before do
      allow(spinner).to receive(:auto_spin)
      allow(spinner).to receive(:success)
    end

    it "starts auto_spin" do
      while_spinning(spinner: spinner, success_message: "Done") { nil }

      expect(spinner).to have_received(:auto_spin)
    end

    it "displays the given success message" do
      while_spinning(spinner: spinner, success_message: "Done") { nil }

      expect(spinner).to have_received(:success).with("Done")
    end

    context "when the given block fails" do
      before do
        allow(spinner).to receive(:auto_spin)
        allow(spinner).to receive(:error)
      end

      it "displays the given error_message" do
        begin
          while_spinning(spinner: spinner, error_message: "Failed") { raise NoMethodError }
        rescue NoMethodError
          # ignore the exception to verify the expectation
        end

        expect(spinner).to have_received(:error).with("Failed")
      end

      it "re-raises the exception" do
        expect do
          while_spinning(spinner: spinner, error_message: "Failed") { raise NoMethodError }
        end.to raise_error NoMethodError
      end
    end

    context "when CI environment variable is set" do
      it "does not call methods on the given spinner instance" do
        ENV["CI"] = "y"
        while_spinning(spinner: spinner, success_message: "Done") { nil }

        expect(spinner).not_to have_received(:auto_spin)
      end
    end
  end
end
