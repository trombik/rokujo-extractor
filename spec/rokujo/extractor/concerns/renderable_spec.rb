# frozen_string_literal: true

RSpec.describe Rokujo::Extractor::Concerns::Renderable do
  include described_class

  describe "#with_spinner" do
    let(:spinner) { instance_double(TTY::Spinner) }

    before do
      allow(spinner).to receive(:auto_spin)
      allow(spinner).to receive(:success)
    end

    it "starts auto_spin" do
      with_spinner(spinner: spinner, success_message: "Done") { nil }

      expect(spinner).to have_received(:auto_spin)
    end

    it "displays the given success message" do
      with_spinner(spinner: spinner, success_message: "Done") { nil }

      expect(spinner).to have_received(:success).with("Done")
    end

    context "when the given block fails" do
      before do
        allow(spinner).to receive(:auto_spin)
        allow(spinner).to receive(:error)
      end

      it "displays the given error_message" do
        begin
          with_spinner(spinner: spinner, error_message: "Failed") { raise NoMethodError }
        rescue NoMethodError
          # ignore the exception to verify the expectation
        end

        expect(spinner).to have_received(:error).with("Failed")
      end

      it "re-raises the exception" do
        expect do
          with_spinner(spinner: spinner, error_message: "Failed") { raise NoMethodError }
        end.to raise_error NoMethodError
      end
    end
  end

  describe "#with_progress" do
    let(:bar) { instance_double(TTY::ProgressBar) }

    before do
      allow(bar).to receive(:stop)
      allow(bar).to receive(:finish)
    end

    it "returns what the block returns" do
      expect(with_progress(progress_bar: bar) { "foo" }).to eq "foo"
    end

    context "when no progress_bar is given" do
      it "creates a TTY::ProgressBar instance itself" do
        allow(TTY::ProgressBar).to receive(:new).and_return(bar)
        with_progress { nil }
        expect(bar).to have_received(:finish)
      end
    end

    context "when the given block fails" do
      it "stops the progress bar" do
        begin
          with_progress(progress_bar: bar) { raise NoMethodError }
        rescue NoMethodError
          # ignore the exception to verify the expectation
        end

        expect(bar).to have_received(:stop)
      end

      it "re-raises the exception" do
        expect do
          with_progress(progress_bar: bar) { raise NoMethodError }
        end.to raise_error NoMethodError
      end
    end
  end

  describe "#widget_enable" do
    let(:dummy) do
      target = described_class
      dummy_class = Class.new do
        include target
      end
      dummy_class.new
    end

    before do
      stub_const("ENV", ENV.to_h.except("CI"))
    end

    context "when environment variable CI is defined" do
      it "returns false" do
        stub_const("ENV", ENV.to_h.merge("CI" => "true"))

        expect(dummy.widget_enable).to be false
      end
    end

    context "when widget_enable is explicitly set to false" do
      it "returns false" do
        dummy.widget_enable = false

        expect(dummy.widget_enable).to be false
      end
    end

    context "when widget_enable is explicitly set to true" do
      it "returns true" do
        dummy.widget_enable = true

        expect(dummy.widget_enable).to be true
      end
    end

    context "when stderr is tty" do
      it "returns true" do
        allow($stderr).to receive(:tty?).and_return(true)

        expect(dummy.widget_enable).to be true
      end
    end

    context "when stderr is not tty" do
      it "returns false" do
        allow($stderr).to receive(:tty?).and_return(false)

        expect(dummy.widget_enable).to be false
      end
    end
  end
end
