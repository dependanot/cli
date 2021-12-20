# frozen_string_literal: true

RSpec.describe GitHub do
  subject { described_class }

  describe ".name_with_owner_from" do
    it "parses the nwo from a ssh url" do
      expect(subject.name_with_owner_from("git@github.com:dependanot/examples.git")).to eq("dependanot/examples")
    end

    it "parses the nwo from a https url" do
      expect(subject.name_with_owner_from("https://github.com/dependanot/examples.git")).to eq("dependanot/examples")
    end
  end
end
