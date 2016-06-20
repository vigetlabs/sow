require 'spec_helper'

RSpec.describe Sprig::DirectiveList do

  describe "#add_seeds_to_hopper" do
    let(:hopper)       { Array.new }
    let(:directive)    { double('directive') }
    let(:seed_factory) { double('seed_factory') }

    subject { described_class.new(Post) }

    before do
      allow(Sprig::Directive).to receive(:new).with(Post).and_return(directive)

      allow(Sprig::Seed::Factory).to receive(:new_from_directive).with(directive).and_return(seed_factory)
    end

    it "builds seeds from directives and adds to the given array" do
      expect(seed_factory).to receive(:add_seeds_to_hopper).with(hopper)

      subject.add_seeds_to_hopper(hopper)
    end
  end
end
