# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rokujo::Extractor::Concerns::SystemSpecific do
  let(:test_class) do
    Class.new do
      include Rokujo::Extractor::Concerns::SystemSpecific
    end
  end
  let(:instance) { test_class.new }
  let(:value_map) { { linux: "bash", bsd: "sh", windows: "cmd.exe", default: "unknown" } }
  let(:proc_map) do
    {
      linux: -> { "bash" },
      bsd: -> { "sh" },
      windows: -> { "cmd.exe" },
      default: -> { raise StandardError, "Unknown OS" }
    }
  end

  describe "#on_os_type" do
    context "when the argument is not a Proc and OS_TYPE is :linux" do
      it "returns bash" do
        stub_const("#{described_class}::OS_TYPE", :linux)
        expect(instance.on_os_type(value_map)).to eq "bash"
      end
    end

    context "when the argument is not a Proc and OS_TYPE is :bsd" do
      it "returns sh" do
        stub_const("#{described_class}::OS_TYPE", :bsd)
        expect(instance.on_os_type(value_map)).to eq "sh"
      end
    end

    context "when the argument is not a Proc and OS_TYPE is :windows" do
      it "returns sh" do
        stub_const("#{described_class}::OS_TYPE", :windows)
        expect(instance.on_os_type(value_map)).to eq "cmd.exe"
      end
    end

    context "when the argument is not a Proc and OS_TYPE is nil" do
      it "returns unknown" do
        stub_const("#{described_class}::OS_TYPE", nil)
        expect(instance.on_os_type(value_map)).to eq "unknown"
      end
    end

    context "when the argument is a Proc and OS_TYPE is :linux" do
      it "returns bash" do
        stub_const("#{described_class}::OS_TYPE", :linux)
        expect(instance.on_os_type(proc_map)).to eq "bash"
      end
    end

    context "when the argument is a Proc and OS_TYPE is :bsd" do
      it "returns sh" do
        stub_const("#{described_class}::OS_TYPE", :bsd)
        expect(instance.on_os_type(proc_map)).to eq "sh"
      end
    end

    context "when the argument is a Proc and OS_TYPE is :windows" do
      it "returns cmd.exe" do
        stub_const("#{described_class}::OS_TYPE", :windows)
        expect(instance.on_os_type(proc_map)).to eq "cmd.exe"
      end
    end

    context "when the argument is a Proc and OS_TYPE is nil" do
      it "raises StandardError" do
        stub_const("#{described_class}::OS_TYPE", nil)
        expect { instance.on_os_type(proc_map) }.to raise_error StandardError
      end
    end
  end
end
